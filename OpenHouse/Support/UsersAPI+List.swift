//
//  UsersAPI+List.swift
//  OpenHouse
//
//  Created by Hue Pham on 17/11/25.
//

import Foundation

extension UsersAPI {
    func getUsers(skip: Int = 0, limit: Int = 100) async throws -> [CRMUser] {
        var url = APIConfig.baseURL.appendingPathComponent("users")
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        url = comps.url!

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        // --- Auth header: choose ONE of the two blocks ---

        // A) Bearer JWT (if your backend accepts Authorization: Bearer ...)
        if let token = self.authToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // B) HTTP Basic (uncomment if your /users still uses Depends(HTTPBasic))
        // let username = "admin"
        // let password = "secret123"
        // let creds = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        // req.setValue("Basic \(creds)", forHTTPHeaderField: "Authorization")

        // Optional: “boring” session avoids compression quirks
        let cfg = URLSessionConfiguration.ephemeral
        cfg.httpAdditionalHeaders = ["Accept": "application/json", "Accept-Encoding": "identity"]
        let session = URLSession(configuration: cfg)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "users", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "GET /users failed (\(http.statusCode)): \(body)"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([CRMUser].self, from: data)
    }
}
