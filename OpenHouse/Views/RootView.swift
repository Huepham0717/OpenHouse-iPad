//
//  RootView.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var state: AppState
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var selection: AppState.Route? = .disclosure

    private var menuItems: [(title: String, icon: String, route: AppState.Route)] = [
        ("Disclosure", "doc.text", .disclosure),
        ("CRM", "person.badge.key", .crm),
        ("Login", "person.badge.key", .login)

    ]

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List(menuItems, id: \.route, selection: $selection) { item in
                if !state.isAuthenticated {
                    if item.route != .crm {
                        NavigationLink(value: item.route) {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                } else {
                    if item.route != .login {
                        NavigationLink(value: item.route) {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                }
            }
            .navigationTitle("Menu")
            if state.isAuthenticated {
                Section {
                    Button(role: .destructive) {
                        state.isAuthenticated = false
                        state.authUsername = ""
                        UsersAPI.shared.authToken = ""
                        state.route = .login
                        selection = .login
                    } label: {
                        Label(
                            state.authUsername.isEmpty ? "Logout" : "Logout \(state.authUsername)",
                            systemImage: "rectangle.portrait.and.arrow.right"
                        )
                    }
                }
            }
        } detail: {
            // Detail wrapped in our custom shell
            DetailShell(
                columnVisibility: $columnVisibility,
                title: title(for: state.route),
                leading: AnyView(
                    Button {
                        withAnimation {
                            columnVisibility = (columnVisibility == .all) ? .detailOnly : .all
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Toggle Sidebar")
                ),
                trailing: state.isAuthenticated ? AnyView(settingsButton) : nil   // ⬅️ hide when logged out
            ) {
                // Your actual content
                switch state.route {
                case .disclosure:   DisclosureView()
                case .info:         VisitorInfoView()
                case .signature:    SignatureView()
                case .done:         DoneView()
                case .login:        LoginView()
                case .crm:         CRMListView()
                }
            }
        }
        .onAppear { selection = state.route }
        .onChange(of: selection) { _, new in if let r = new { state.route = r } }
        .onChange(of: state.route) { _, new in selection = new }
        .tint(.black)
    }

    private func title(for route: AppState.Route) -> String {
        switch route {
        case .disclosure: "Disclosure"
        case .info:       "Info"
        case .signature:  "Signature"
        case .done:       "Done"
        case .login:      "Login"
            case .crm:        "CRM"
        }
    }

    private var settingsButton: some View {
        Button {
            state.showSettings = true
        } label: {
            Image(systemName: "gearshape.fill").imageScale(.large)
        }
        .sheet(isPresented: $state.showSettings) {
            AgentSettingsView().environmentObject(state)
        }
        .accessibilityLabel("Agent Settings")
    }
}


struct RootView_Previews: PreviewProvider {
static var previews: some View {
RootView()
.environmentObject(AppState())
}
}
