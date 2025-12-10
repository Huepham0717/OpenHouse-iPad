//
//  CRMView.swift
//  OpenHouse
//
//  Created by Hue Pham on 22/10/25.
//

// Views/CRMUsersView.swift
import SwiftUI

@MainActor
final class CRMUsersVM: ObservableObject {
    @Published var users: [CRMUser] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await UsersAPI.shared.getUsers(skip: 0, limit: 100)
            self.users = result
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    var filtered: [CRMUser] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return users }
        return users.filter {
            $0.fullName.lowercased().contains(q) ||
            $0.email.lowercased().contains(q) ||
            $0.phone.lowercased().contains(q)
        }
    }
}

struct CRMListView: View {
    @StateObject private var vm = CRMUsersVM()

    var body: some View {
        NavigationStack {
            List(vm.filtered) { user in
                CRMUserRow(user: user)
            }
            .overlay {
                if vm.isLoading && vm.users.isEmpty {
                    ProgressView().scaleEffect(1.2)
                } else if vm.users.isEmpty {
                    ContentUnavailableView("No users", systemImage: "person.3", description: Text("Pull to refresh"))
                }
            }
            .refreshable { await vm.load() }
            .navigationTitle("Users")
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .task { await vm.load() }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil), presenting: vm.errorMessage) { _ in
                Button("OK") { vm.errorMessage = nil }
            } message: { msg in
                Text(msg)
            }
        }
    }
}

private struct CRMUserRow: View {
    let user: CRMUser
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(user.fullName).font(.headline)
                Spacer()
                Text(user.email).font(.subheadline).foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            HStack(spacing: 12) {
                Label(user.phone, systemImage: "phone").font(.subheadline)
                if let note = user.note, !note.isEmpty {
                    Text("•").foregroundStyle(.secondary)
                    Text(note).lineLimit(1).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
