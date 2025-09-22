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
        VStack(alignment: .leading, spacing: 12) {

            // -------- Header (matches C.A.R. style) --------
            VStack(alignment: .leading, spacing: 6) {
                Text("VISITOR SIGN-IN SECTION")
                    .font(.title3).bold()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Divider().padding(.horizontal, 20)

            // -------- Form content --------
            Form {
                Section {
                    TextField("Full Name", text: $state.currentVisitor.fullName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .name)

                    TextField("Email", text: $state.currentVisitor.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .email)

                    TextField("Phone", text: $state.currentVisitor.phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .focused($focusedField, equals: .phone)

                    Toggle("Do you have an agent?", isOn: $state.currentVisitor.hasAgent)
                }

                if state.currentVisitor.hasAgent {
                    Section {
                        TextField("Agent Name", text: $state.currentVisitor.agentName)
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .agentName)

                        TextField("Agent Email", text: $state.currentVisitor.agentEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .agentEmail)

                        TextField("Agent Phone", text: $state.currentVisitor.agentPhone)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .agentPhone)
                    } header: {
                        Text("Visitor’s Agent (if any)")
                    }
                }
            }
            .contentMargins(.top, 12, for: .scrollContent) // keeps a little space under header
            .scrollDismissesKeyboard(.interactively)

            Divider().padding(.horizontal, 20)

            // -------- Footer (light legal text) --------
            VStack(alignment: .leading, spacing: 8) {
                Text("© 2024, California Association of REALTORS®, Inc.")
                Text("United States copyright law (Title 17 U.S. Code) forbids the unauthorized distribution, display and reproduction of this form, or any portion thereof, by photocopy machine or any other means, including facsimile or computerized formats.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 4)

                Group {
                    Text("THIS FORM HAS BEEN APPROVED BY THE CALIFORNIA ASSOCIATION OF REALTORS®.").bold()
                    Text("NO REPRESENTATION IS MADE AS TO THE LEGAL VALIDITY OR ACCURACY OF ANY PROVISION IN ANY SPECIFIC TRANSACTION.")
                    Text("A REAL ESTATE BROKER IS THE PERSON QUALIFIED TO ADVISE ON REAL ESTATE TRANSACTIONS.")
                    Text("IF YOU DESIRE LEGAL OR TAX ADVICE, CONSULT AN APPROPRIATE PROFESSIONAL.")
                }

                Text("This form is made available to real estate professionals through an agreement with or purchase from the California Association of REALTORS®.")
                    .padding(.top, 4)

                Group {
                    Text("Published and Distributed by:").bold()
                    Text("REAL ESTATE BUSINESS SERVICES, LLC.")
                    Text("a subsidiary of the California Association of REALTORS®")
                }

                Group {
                    Text("OHNA-SI REVISED 12/24 (PAGE 1 OF 1)")
                    Text("OPEN HOUSE VISITOR NON-AGENCY DISCLOSURE AND SIGN-IN (OHNA-SI PAGE 1 OF 1)")
                        .padding(.bottom, 4)
                }

                Group {
                    Text("Phone:  Fax:")
                    Text("Produced with Lone Wolf Transactions (zipForm Edition)")
                    Text("717 N Harwood St, Suite 2200, Dallas, TX 75201")
                    Link("www.lwolf.com", destination: URL(string: "https://www.lwolf.com")!)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

        }
        .toolbar { ToolbarItemGroup(placement: .bottomBar) { bottomBar } }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Sign-In")
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
        !state.currentVisitor.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !state.currentVisitor.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview("VisitorInfoView") {
    let state = PreviewState.sample(route: .info)
    return NavigationStack { VisitorInfoView().environmentObject(state) }
}
