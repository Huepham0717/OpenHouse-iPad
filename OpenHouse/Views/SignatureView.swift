//
//  SignatureView.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI
import PencilKit

struct SignatureView: View {
    @EnvironmentObject var state: AppState
    @State private var canvasView = PKCanvasView()
    @State private var hasDrawing = false   // track if user drew anything

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Signature").font(.largeTitle).bold()
            Text("Sign Below:").font(.headline)

            SignatureCanvas(canvasView: $canvasView, hasDrawing: $hasDrawing)
                .frame(height: 280)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray, lineWidth: 1)
                )
                .padding(.bottom, 12)

            HStack {
                Button("Clear") {
                    canvasView.drawing = PKDrawing()
                    hasDrawing = false
                }
                Spacer()
                Button("Back") { state.route = .info }
                Button("Done") { finalize() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!hasDrawing)   // now uses our state flag
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }

    private func finalize() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        state.completeSignature(with: image)
    }
}

struct SignatureCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var hasDrawing: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.alwaysBounceVertical = false
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 4)
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SignatureCanvas
        init(_ parent: SignatureCanvas) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.hasDrawing = !canvasView.drawing.strokes.isEmpty
        }
    }
}


#Preview("SignatureView") {
let state = PreviewState.sample(route: .signature)
return NavigationStack { SignatureView().environmentObject(state) }
}
