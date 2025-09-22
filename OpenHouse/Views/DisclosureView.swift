//
//  DisclosureView.swift
//  OpenHouse
//
//  Created by Hue Pham on 22/9/25.
//
import SwiftUI

struct DisclosureView: View {
    @EnvironmentObject var state: AppState
    @State private var isChecked = false

    var body: some View {
        VStack(spacing: 24) {
            Text(state.agentSettings.propertyAddress)
                .font(.largeTitle).bold()
                .padding(.top, 32)

            Text("Welcome! Please read the disclosure before signing in.")
                .font(.title3)
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DisclosureText()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
                .frame(maxWidth: 820)
            }

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
}

struct DisclosureText: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Open House Disclosure").font(.title2).bold()
            Group {
                disc("AGENT DOES NOT REPRESENT VISITOR:", "Agent is representing the seller exclusively. Any information Visitor reveals to Agent will be disclosed to the seller. Unless Visitor has a written agreement with Agent for representation, Agent does not represent Visitor.")
                disc("COMMUNICATION WITH AGENT AT OPEN HOUSE/PROPERTY TOUR FOR BENEFIT OF SELLER:", "Any questions or discussion with Agent at the open house/property tour are for the benefit of the seller.")
                disc("SOLICITATION, WHAT AGENT MAY OR MAY NOT DO:", "Agent may not solicit Visitor if Visitor is represented under a valid written agreement with another agent. Agent may respond to Visitor’s questions, but solicitation for representation is not permitted.")
                disc("AGENT AT OPEN HOUSE/PROPERTY TOUR MAY RECEIVE INFORMATION:", "Any information Visitor reveals may be conveyed to the seller by the Agent.")
                disc("IF VISITOR WANTS TO BE REPRESENTED BY AGENT HOLDING THE OPEN HOUSE:", "Visitor should enter into a written Buyer Representation Agreement (BRA) with that Agent before proceeding further. Without such agreement, Agent represents only the seller.")
            }
            Text("Note: Real estate broker commissions are not set by law and are fully negotiable.")
                .italic()
            Divider()
        }
    }
    private func disc(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).bold()
            Text(body)
        }
    }
}

#Preview("DisclosureView") {
    let state = PreviewState.sample(route: .disclosure)
    return DisclosureView().environmentObject(state)
}
