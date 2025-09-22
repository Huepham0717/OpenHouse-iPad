//
//  PreviewData.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI
#if DEBUG


enum PreviewState {
static func sample(route: AppState.Route? = nil) -> AppState {
let state = AppState()
state.agentSettings = AgentSettingsModel(
propertyAddress: "1833 Gale Ave, Hermosa Beach, CA",
brokerageTeam: "Compass HB Team",
agentOfRecord: "Alex Agent"
)
let visitor = Visitor(
fullName: "Taylor Brooks",
email: "taylor@example.com",
phone: "(555) 123-4567",
hasAgent: true,
agentName: "Jordan Lee",
agentEmail: "jordan@broker.com",
agentPhone: "(555) 987-6543",
agreedToDisclosure: true,
signedAt: Date(),
signatureImagePNGData: fakeSignaturePNG()
)
state.currentVisitor = visitor
state.visitors = [visitor]
if let r = route { state.route = r }
return state
}


private static func fakeSignaturePNG() -> Data? {
let size = CGSize(width: 600, height: 240)
let renderer = UIGraphicsImageRenderer(size: size)
let img = renderer.image { ctx in
UIColor.white.setFill(); ctx.fill(CGRect(origin: .zero, size: size))
let path = UIBezierPath()
path.move(to: CGPoint(x: 30, y: 160))
path.addCurve(to: CGPoint(x: 220, y: 80), controlPoint1: CGPoint(x: 90, y: 120), controlPoint2: CGPoint(x: 150, y: 60))
path.addCurve(to: CGPoint(x: 420, y: 170), controlPoint1: CGPoint(x: 300, y: 110), controlPoint2: CGPoint(x: 360, y: 190))
path.addCurve(to: CGPoint(x: 560, y: 100), controlPoint1: CGPoint(x: 480, y: 150), controlPoint2: CGPoint(x: 520, y: 120))
path.lineWidth = 4
UIColor.black.setStroke()
path.stroke()
}
return img.pngData()
}
}
#endif
