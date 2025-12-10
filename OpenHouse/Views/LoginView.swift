//
//  LoginView.swift
//  OpenHouse
//
//  Created by Hue Pham on 16/10/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var state: AppState
    @State private var username = ""
    @State private var password = ""
    @State private var error: String?
    @State private var isLoading = false
    @FocusState private var focused: Field?
    enum Field { case user, pass }

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Agent Login").font(.largeTitle).bold()
            Section {
                GeometryReader { geo in
                    // spacing between the two fields
                    let gap: CGFloat = 16
                    let half = (geo.size.width - gap) / 2

                    VStack( alignment: .leading, spacing: gap) {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(.username)
                            .focused($focused, equals: .user)
                            .frame(width: half)

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .focused($focused, equals: .pass)

                            .frame(width: half)
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                // IMPORTANT: give the GeometryReader row a height in a Form
                .frame(height: 56)
            }

            if let error { Text(error).foregroundStyle(.red).font(.footnote) }

            HStack{
                Spacer()
                Button("Sign In") { Task { await signIn() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || username.isEmpty || password.isEmpty)

                if isLoading { ProgressView().padding(.leading, 8) }
                Spacer()
            }
            .padding(.top, 20.0)
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding(.horizontal)
        .onAppear { focused = .user }
    }
    
    @MainActor
    private func signIn() async {
        print("➡️ signIn() start for user:", username)
        self.error = nil
        isLoading = true
        defer { isLoading = false; print("⬅️ signIn() end") }

        do {
            let res = try await UsersAPI.shared.login(username: username, password: password)
            print("✅ Login OK. token prefix:", res.access_token.prefix(10))

            state.isAuthenticated = true
            state.authUsername = username
             state.route = .disclosure
        } catch {
            print("❌ signIn error:", error)
            state.isAuthenticated = false
            self.error = (error as? LocalizedError)?.errorDescription ?? "Login failed"
        }
    }
}
#Preview {
    LoginView()
}
