//
//  VisitorInfoView.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI

struct VisitorInfoView: View {
    @EnvironmentObject var state: AppState
    @FocusState private var focusedField: Field?
    enum Field { case name, email, phone, agentName, agentEmail, agentPhone }

    var body: some View {
        Form {
            Section(header: Text("Visitor Information").font(.title2)) {
                TextField("Full Name", text: $state.currentVisitor.fullName)
                    .textContentType(.name)
                    .focused($focusedField, equals: .name)
                TextField("Email", text: $state.currentVisitor.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .focused($focusedField, equals: .email)
                TextField("Phone", text: $state.currentVisitor.phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .focused($focusedField, equals: .phone)
                Toggle("Do you have an agent?", isOn: $state.currentVisitor.hasAgent)
            }
            if state.currentVisitor.hasAgent {
                Section(header: Text("Buyer’s Agent")) {
                    TextField("Agent Name", text: $state.currentVisitor.agentName)
                        .focused($focusedField, equals: .agentName)
                    TextField("Agent Email", text: $state.currentVisitor.agentEmail)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .agentEmail)
                    TextField("Agent Phone", text: $state.currentVisitor.agentPhone)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .agentPhone)
                }
            }
        }
        .toolbar { ToolbarItemGroup(placement: .bottomBar) { bottomBar } }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Sign-In")
        .contentMargins(.top, 50, for: .scrollContent) 
    }

    private var bottomBar: some View {
        HStack {
            Button("Back") { state.route = .disclosure }
            Spacer()
            Button("Next") { state.route = .signature }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
        }
    }

    private var canProceed: Bool {
        !state.currentVisitor.fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !state.currentVisitor.email.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

#Preview("VisitorInfoView") {
let state = PreviewState.sample(route: .info)
return NavigationStack { VisitorInfoView().environmentObject(state) }
}
