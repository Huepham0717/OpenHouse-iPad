//
//  Visitor.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import Foundation


struct Visitor: Identifiable, Codable {
let id: UUID
var fullName: String
var email: String
var phone: String
var hasAgent: Bool
var agentName: String
var agentEmail: String
var agentPhone: String
var agreedToDisclosure: Bool
var signedAt: Date?
var signatureImagePNGData: Data?


init(
id: UUID = UUID(),
fullName: String = "",
email: String = "",
phone: String = "",
hasAgent: Bool = false,
agentName: String = "",
agentEmail: String = "",
agentPhone: String = "",
agreedToDisclosure: Bool = false,
signedAt: Date? = nil,
signatureImagePNGData: Data? = nil
) {
self.id = id
self.fullName = fullName
self.email = email
self.phone = phone
self.hasAgent = hasAgent
self.agentName = agentName
self.agentEmail = agentEmail
self.agentPhone = agentPhone
self.agreedToDisclosure = agreedToDisclosure
self.signedAt = signedAt
self.signatureImagePNGData = signatureImagePNGData
}
}
