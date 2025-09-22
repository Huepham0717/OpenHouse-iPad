//
//  AgentSettingsView.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI

struct AgentSettingsView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Agent Settings").font(.title2)) {
                    TextField("Property Address", text: $state.agentSettings.propertyAddress)
                    TextField("Brokerage/Team", text: $state.agentSettings.brokerageTeam)
                    TextField("Agent of Record", text: $state.agentSettings.agentOfRecord)
                }

                Section(header: Text("Sign-ins")) {
                    if state.visitors.isEmpty {
                        Text("No sign-ins yet.").foregroundStyle(.secondary)
                    } else {
                        List(state.visitors) { v in
                            VStack(alignment: .leading) {
                                Text(v.fullName).bold()
                                Text(v.email).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .frame(minHeight: 120, maxHeight: 320)
                    }

                    HStack {
                        Button("Export CSV") { exportCSV() }
                        Button("Clear All Sign-ins", role: .destructive) {
                            state.visitors.removeAll(); state.save()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { state.save(); dismiss() }
                }
            }
            .navigationTitle("Agent Settings")
        }
        .sheet(isPresented: $state.showShareExporter) {
            ShareSheet(activityItems: state.exporterItems)
        }
    }

    private func dismiss() { state.showSettings = false }
    private func exportCSV() {
        if let url = state.exportCSV() { state.exporterItems = [url]; state.showShareExporter = true }
    }
}

struct AgentSettingsView_Previews: PreviewProvider {
static var previews: some View {
    AgentSettingsView()
    .environmentObject(AppState())
    }
}
