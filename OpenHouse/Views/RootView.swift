//
//  RootView.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                switch state.route {
                case .disclosure: DisclosureView()
                case .info: VisitorInfoView()
                case .signature: SignatureView()
                case .done: DoneView()
                }
                settingsButton
            }
            .navigationBarHidden(true)
        }
        .tint(.black)
    }

    private var settingsButton: some View {
        Button { state.showSettings = true } label: {
            Image(systemName: "gearshape.fill").font(.title)
                .padding(16)
                .background(.ultraThinMaterial, in: Circle())
                .padding([.top, .trailing], 24)
        }
        .sheet(isPresented: $state.showSettings) { AgentSettingsView().environmentObject(state) }
        .accessibilityLabel("Agent Settings")
    }
}

struct RootView_Previews: PreviewProvider {
static var previews: some View {
RootView()
.environmentObject(AppState())
}
}
