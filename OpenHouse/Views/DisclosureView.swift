//
//  DisclosureView.swift
//  OpenHouse
//
//  Created by Hue Pham on 22/9/25.
//
import SwiftUI

private func numberedSection(number: Int, title: String, body: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        HStack(alignment: .top, spacing: 6) {
            Text("\(number).")
                .bold()
            VStack(alignment: .leading, spacing: 4) {
                Text(title).bold()
                Text(body)
            }
        }
    }
}

struct DisclosureView: View {
    @EnvironmentObject var state: AppState
    @State private var isChecked = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
            // Main title
            Text("OPEN HOUSE VISITOR NON-AGENCY DISCLOSURE AND SIGN-IN")
                .font(.system(size: 24, weight: .heavy))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            // Subtitle
            VStack(spacing: 4) {
                Text("(Can be used for open house or individual private showings)")
                Text("(C.A.R. Form OHNA-SI, Revised 12/24)")
            }
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            Divider().padding(.vertical, 8)

            // Property and agent info
            VStack(alignment: .leading, spacing: 8) {
                Text("Property address (\"Property\"): \(state.agentSettings.propertyAddress)")
                    .bold()
                HStack(spacing: 6) {
                    Text("Date:").bold()
                    Text(Date.now.formatted(.dateTime.day().month().year())) // 8 Oct 2025
                    // or: .dateTime.month(.wide).day().year()  -> October 8, 2025
                }
                Text("Real estate agent(s) (\"Agent\"): \(state.agentSettings.agentOfRecord)")
                    .bold()
                Text("Real estate broker (\"Broker\"): \(state.agentSettings.brokerageTeam)")
                    .bold()
            }
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("VISITOR INTENTION TO VIEW PROPERTY")
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 4)

                    Text("""
            Agent is holding an open house or conducting in-person or live virtual tours of the Property identified above. Visitor is interested in viewing the Property. Agent agrees to show property to Visitor on the following terms and conditions:
            """)

                    Group {
                        numberedSection(
                            number: 1,
                            title: "AGENT DOES NOT REPRESENT VISITOR",
                            body: "Unless otherwise agreed in writing, Agent is not working with and has not entered into a representation agreement with Visitor that would apply to the Property."
                        )

                        numberedSection(
                            number: 2,
                            title: "COMMUNICATION WITH AGENT AT OPEN HOUSE/PROPERTY TOUR FOR BENEFIT OF SELLER",
                            body: "Any communication or sharing of information that Agent has with Visitor during the open house/property tour regarding the Property is for the benefit of the seller. All acts of Agent at the open house/property tour, even those that assist Visitor in deciding whether to make an offer on the Property are for the benefit of the seller exclusively."
                        )

                        numberedSection(
                            number: 3,
                            title: "COMMUNICATION WITH AGENT ARE NOT CONFIDENTIAL",
                            body: "Any information that Visitor reveals to Agent at the open house/property tour may be conveyed to the seller."
                        )

                        numberedSection(
                            number: 4,
                            title: "IF VISITOR WRITES AN OFFER ON THE PROPERTY",
                            body: "Through Agent, at that time Agent will disclose if Agent and Agent’s Broker represent the seller exclusively or both the seller and the Visitor."
                        )

                        numberedSection(
                            number: 5,
                            title: "IF VISITOR WANTS TO BE REPRESENTED BY THE AGENT HOLDING THE OPEN HOUSE",
                            body: "Visitor should sign a representation agreement with the Agent holding the open house such as a Property Showing and Representation Agreement (C.A.R. Form PSRA) or Buyer Representation and Broker Compensation Agreement (C.A.R. Form BRBC). If Visitor is in an exclusive relationship with another agent, this is not intended as a solicitation of Visitor."
                        )
                    }

                    Text("Note: Real estate broker commissions are not set by law and are fully negotiable.")
                        .italic()
                        .padding(.top, 4)
                }
                .padding()
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
            .frame(maxWidth: 820)


            Toggle(isOn: $isChecked) {
                Text("I have read and agree to the terms").font(.headline)
            }
            .toggleStyle(.switch)
            .frame(maxWidth: 820, alignment: .leading)

            HStack(spacing: 16) {
                Button("Back") { }
                    .buttonStyle(.bordered)
                    .disabled(true)
                Spacer().frame(width: 16)
                Button("Continue to Sign-In") {
                    state.currentVisitor.agreedToDisclosure = isChecked
                    state.route = .info
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isChecked)
            }
            .frame(maxWidth: 820)
            .padding(.bottom, 32)
        }
        .padding()
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).bold()
            Text(body)
        }
    }
}

#Preview("DisclosureView Updated") {
    let state = PreviewState.sample(route: .disclosure)
    return DisclosureView().environmentObject(state)
}

