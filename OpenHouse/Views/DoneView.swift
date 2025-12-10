//
//  DoneView.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI

struct DoneView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 20) {
            if state.isSubmittingUser {
                Label("Submitting to server…", systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline)
            } else if let u = state.lastCreatedUser {
                Label("Synced as #\(u.id) • \(u.first_name) \(u.last_name)", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline)
            } else if let err = state.lastAPIError {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.subheadline)
            }
            Text("You're All Set").font(.largeTitle).bold()
            Text("Thanks for signing in. A copy can be printed or saved as PDF.")
                .foregroundStyle(.secondary)
            SummaryCard(visitor: state.currentVisitor)
                .frame(maxWidth: 820)

            HStack(spacing: 12) {
                Button("Print/Save PDF") { exportPDF() }.buttonStyle(.borderedProminent)
                Button("Finish") {
                    state.resetCurrent(); state.route = .disclosure
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .sheet(isPresented: $state.showShareExporter) { ShareSheet(activityItems: state.exporterItems) }
        .navigationBarBackButtonHidden(true)
    }

    private func exportPDF() {
        guard let url = state.exportPDF(for: state.currentVisitor) else { return }
        state.exporterItems = [url]
        state.showShareExporter = true
    }
}

struct SummaryCard: View {
    let visitor: Visitor
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary").font(.title2).bold()
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                row("Name", visitor.fullName)
                row("Email", visitor.email)
                row("Phone", visitor.phone)
                row("Has Agent", visitor.hasAgent ? "Yes" : "No")
                if visitor.hasAgent {
                    row("Agent Name", visitor.agentName)
                    row("Agent Email", visitor.agentEmail)
                    row("Agent Phone", visitor.agentPhone)
                }
                row("Agreed Disclosure", visitor.agreedToDisclosure ? "Yes" : "No")
                row("Signed At", visitor.signedAt.map{ DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short) } ?? "—")
            }
            if let data = visitor.signatureImagePNGData, let ui = UIImage(data: data) {
                Divider().padding(.vertical, 8)
                Text("Signature").font(.headline)
                Image(uiImage: ui).resizable().scaledToFit().frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
    }
    @ViewBuilder private func row(_ k: String, _ v: String) -> some View {
        GridRow { Text(k).bold(); Text(v) }
    }
}

#Preview("DoneView") {
let state = PreviewState.sample(route: .done)
return NavigationStack { DoneView().environmentObject(state) }
}
