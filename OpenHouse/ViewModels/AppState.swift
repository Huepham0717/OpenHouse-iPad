//
//  AppState.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI
import PDFKit

final class AppState: ObservableObject {
    enum Route { case disclosure, info, signature, done }

    // Navigation & Data
    @Published var route: Route = .disclosure
    @Published var currentVisitor = Visitor()
    @Published var visitors: [Visitor] = []

    // Settings & export
    @Published var agentSettings = AgentSettingsModel()
    @Published var showSettings = false
    @Published var showShareExporter = false
    @Published var exporterItems: [URL] = []

    // Persistence keys
    private let visitorsKey = "openhouse.visitors"
    private let settingsKey = "openhouse.settings"

    init() { load() }

    // MARK: Persistence
    func load() {
        if let vData = UserDefaults.standard.data(forKey: visitorsKey),
           let decoded = try? JSONDecoder().decode([Visitor].self, from: vData) {
            visitors = decoded
        }
        if let sData = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AgentSettingsModel.self, from: sData) {
            agentSettings = decoded
        }
    }

    func save() {
        if let v = try? JSONEncoder().encode(visitors) {
            UserDefaults.standard.set(v, forKey: visitorsKey)
        }
        if let s = try? JSONEncoder().encode(agentSettings) {
            UserDefaults.standard.set(s, forKey: settingsKey)
        }
    }

    // MARK: Flow helpers
    func resetCurrent() { currentVisitor = Visitor() }

    func completeSignature(with image: UIImage) {
        currentVisitor.signatureImagePNGData = image.pngData()
        currentVisitor.signedAt = Date()
        visitors.append(currentVisitor)
        save()
        route = .done
    }

    // MARK: Exports
    func exportCSV() -> URL? {
        let headers = [
            "Full Name","Email","Phone","Has Agent","Agent Name","Agent Email","Agent Phone","Agreed Disclosure","Signed At"
        ]
        var rows: [String] = [headers.joined(separator: ",")]
        let df = ISO8601DateFormatter()
        for v in visitors {
            let r: [String] = [
                escapeCSV(v.fullName),
                escapeCSV(v.email),
                escapeCSV(v.phone),
                v.hasAgent ? "Yes" : "No",
                escapeCSV(v.agentName),
                escapeCSV(v.agentEmail),
                escapeCSV(v.agentPhone),
                v.agreedToDisclosure ? "Yes" : "No",
                v.signedAt.map { df.string(from: $0) } ?? ""
            ]
            rows.append(r.joined(separator: ","))
        }
        let csv = rows.joined(separator: "")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("OpenHouseSignIns.csv")
        do { try csv.data(using: .utf8)?.write(to: url); return url } catch { return nil }
    }

    func exportPDF(for visitor: Visitor) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("OpenHouse_\(visitor.id.uuidString.prefix(8)).pdf")
        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                let title = "Open House Sign-In Summary"
                let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 24)]
                title.draw(at: CGPoint(x: 36, y: 36), withAttributes: titleAttrs)

                let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
                var y: CGFloat = 90
                func drawLine(_ text: String) { (text as NSString).draw(at: CGPoint(x: 36, y: y), withAttributes: bodyAttrs); y += 24 }

                drawLine("Property: \(agentSettings.propertyAddress)")
                if !agentSettings.brokerageTeam.isEmpty { drawLine("Brokerage/Team: \(agentSettings.brokerageTeam)") }
                if !agentSettings.agentOfRecord.isEmpty { drawLine("Agent of Record: \(agentSettings.agentOfRecord)") }
                y += 12
                drawLine("Visitor: \(visitor.fullName)")
                drawLine("Email: \(visitor.email)")
                drawLine("Phone: \(visitor.phone)")
                drawLine("Has Agent: \(visitor.hasAgent ? "Yes" : "No")")
                if visitor.hasAgent {
                    if !visitor.agentName.isEmpty { drawLine("Agent Name: \(visitor.agentName)") }
                    if !visitor.agentEmail.isEmpty { drawLine("Agent Email: \(visitor.agentEmail)") }
                    if !visitor.agentPhone.isEmpty { drawLine("Agent Phone: \(visitor.agentPhone)") }
                }
                drawLine("Agreed to Disclosure: \(visitor.agreedToDisclosure ? "Yes" : "No")")
                drawLine("Signed At: \(visitor.signedAt.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short) } ?? "—")")

                if let data = visitor.signatureImagePNGData, let img = UIImage(data: data) {
                    let sigY = y + 24
                    let sigRect = CGRect(x: 36, y: sigY, width: 300, height: 120)
                    ("Signature" as NSString).draw(at: CGPoint(x: 36, y: sigY - 18), withAttributes: bodyAttrs)
                    img.draw(in: sigRect)
                }
            }
            return url
        } catch { return nil }
    }
}
