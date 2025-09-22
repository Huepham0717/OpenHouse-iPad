//
//  API.swift
//  OpenHouse
//
//  Created by Hue Pham on 8/10/25.
//

import Foundation

enum APIConfig {
    #if targetEnvironment(simulator)
    static let baseURL = URL(string: "https://rei-service-844999908851.us-central1.run.app")!     // Simulator -> your Mac
//    static let baseURL = URL(string: "http://localhost:8000")! 
    #else
    static let baseURL = URL(string: "http://192.168.0.100:8000")! // Device -> replace with Mac LAN IP
    #endif
}

enum APIError: Error, LocalizedError {
    case message(String)
    case transport(Error)
    case badStatus(Int)

    var errorDescription: String? {
        switch self {
        case .message(let m): return m
        case .transport(let e): return e.localizedDescription
        case .badStatus(let c): return "HTTP \(c)"
        }
    }
}


final class UsersAPI {
    static let shared = UsersAPI()
    private let session: URLSession
    private var basicAuthHeader: String? = nil
    // Store token for authenticated requests
    @Published var authToken: String?

    private init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 15
        cfg.timeoutIntervalForResource = 30
        session = URLSession(configuration: cfg)
    }
    
    // Set credentials for future requests
    func setCredentials(username: String, password: String) {
        let raw = "\(username):\(password)"
        if let data = raw.data(using: .utf8) {
            basicAuthHeader = "Basic " + data.base64EncodedString()
        }
    }

    func clearCredentials() { basicAuthHeader = nil }

    // Quick auth check: call a protected endpoint (GET /users?limit=1)
    func testAuth() async throws {
        var url = APIConfig.baseURL
        url.append(path: "/users")
        var req = URLRequest(url: url.appending(queryItems: [URLQueryItem(name: "limit", value: "1")]))
        req.httpMethod = "GET"
        if let h = basicAuthHeader { req.setValue(h, forHTTPHeaderField: "Authorization") }

        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.message("Invalid username/password")
        }
    }

    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return f
    }()
    
    func createUser(_ payload: UserCreate) async throws -> UserResponseDTO {
        var url = APIConfig.baseURL
        if #available(iOS 16.0, *) {
            url.append(path: "/users")
        } else {
            url = url.appendingPathComponent("users")
        }
        print("Payload:", payload)

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let body = try encoder.encode(payload)
        req.httpBody = body

        do {
            let (data, resp) = try await session.data(for: req)

            // 🔥 PRINT RAW RESPONSE FROM FASTAPI
            if let raw = String(data: data, encoding: .utf8) {
                print("🔥 Raw Response JSON:", raw)
            }

            guard let http = resp as? HTTPURLResponse else {
                throw APIError.message("No HTTP response")
            }

            if (400...499).contains(http.statusCode) {
                if let detail = (try? JSONDecoder().decode([String:String].self, from: data))?["detail"] {
                    throw APIError.message(detail)
                }
                throw APIError.badStatus(http.statusCode)
            }

            guard (200...299).contains(http.statusCode) else {
                throw APIError.badStatus(http.statusCode)
            }

            let dec = JSONDecoder()
            dec.dateDecodingStrategy = .iso8601

            return try dec.decode(UserResponseDTO.self, from: data)

        } catch {
            throw (error as? APIError) ?? APIError.transport(error)
        }
    }


    struct LoginResponse: Codable {
        let access_token: String
        let token_type: String
        let expires_in: Int
    }

    private func makeJSONRequest(url: URL,
                         body: [String: Any],
                         closeConnection: Bool) throws -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if closeConnection {
            req.setValue("close", forHTTPHeaderField: "Connection")
        }

        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        return req
    }
    
    private func freshSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpShouldUsePipelining = false
        config.waitsForConnectivity = true
        // (optionally) limit simultaneous connections:
        config.httpMaximumConnectionsPerHost = 2
        return URLSession(configuration: config)
    }

    
    func login(username: String, password: String) async throws -> LoginResponse {
        let base = APIConfig.baseURL // https://rei-service-...run.app
        let url  = base.appendingPathComponent("login")

        // 1) First attempt: fresh session, normal keep-alive
        do {
            let req = try makeJSONRequest(url: url,
                                          body: ["username": username, "password": password],
                                          closeConnection: false)

            print("➡️ Login request (1st):", req)

            let (data, resp) = try await freshSession().data(for: req)

            if let http = resp as? HTTPURLResponse {
                print("⬅️ Login response (1st) status:", http.statusCode)
                print("⬅️ Login response (1st) headers:", http.allHeaderFields)
            } else {
                print("⬅️ Login response (1st): not HTTPURLResponse:", resp)
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("⬅️ Login raw body (1st):", raw)
            }

            guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
            guard (200...299).contains(http.statusCode) else {
                let msg = String(data: data, encoding: .utf8) ?? ""
                throw NSError(domain: "login", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: "Login failed (\(http.statusCode)): \(msg)"])
            }

            let res = try JSONDecoder().decode(LoginResponse.self, from: data)
            UsersAPI.shared.authToken = res.access_token
            return res

        } catch {
            let nsErr = error as NSError
            print("❌ Login 1st attempt error:", nsErr, nsErr.code)

            let isTransportGlitch = nsErr.domain == NSURLErrorDomain &&
                (nsErr.code == -1005 || nsErr.code == -1017)

            if !isTransportGlitch { throw error }
        }

        // 2) Retry once with a brand-new session and Connection: close
        let retryReq = try makeJSONRequest(url: url,
                                           body: ["username": username, "password": password],
                                           closeConnection: true)

        print("➡️ Login request (retry):", retryReq)

        let (retryData, retryResp) = try await freshSession().data(for: retryReq)

        if let http = retryResp as? HTTPURLResponse {
            print("⬅️ Login response (retry) status:", http.statusCode)
            print("⬅️ Login response (retry) headers:", http.allHeaderFields)
        } else {
            print("⬅️ Login response (retry): not HTTPURLResponse:", retryResp)
        }

        if let raw = String(data: retryData, encoding: .utf8) {
            print("⬅️ Login raw body (retry):", raw)
        }

        guard let retryHTTP = retryResp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(retryHTTP.statusCode) else {
            let msg = String(data: retryData, encoding: .utf8) ?? ""
            throw NSError(domain: "login", code: retryHTTP.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Login failed (\(retryHTTP.statusCode)): \(msg)"])
        }

        let retryRes = try JSONDecoder().decode(LoginResponse.self, from: retryData)
        UsersAPI.shared.authToken = retryRes.access_token
        return retryRes
    }

}

// Tiny helper
private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        var c = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        c.queryItems = (c.queryItems ?? []) + queryItems
        return c.url!
    }
}
