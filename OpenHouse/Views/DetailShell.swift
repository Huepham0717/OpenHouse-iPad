//
//  DetailShell.swift
//  OpenHouse
//
//  Created by Hue Pham on 14/10/25.
//

import SwiftUI

/// A wrapper that provides a custom top bar and hides the system nav bar.
/// Works on iOS 16+ (no special APIs).
struct DetailShell<Content: View>: View {
    @Binding var columnVisibility: NavigationSplitViewVisibility
    let title: String
    let leading: AnyView?        // put your hamburger here
    let trailing: AnyView?       // put settings/help here
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Leading
                if let leading { leading }
                // Title
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                // Trailing
                if let trailing { trailing }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar) // <-- hides system bar on all iOS versions
    }
}
#Preview {
    
}
