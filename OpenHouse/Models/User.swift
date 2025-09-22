//
//  User.swift
//  OpenHouse
//
//  Created by Hue Pham on 17/11/25.
//

import Foundation

struct CRMUser: Identifiable, Codable, Hashable {
    let id: Int
    let first_name: String
    let last_name: String
    let email: String
    let phone: String
    let note: String?
    let created_at: Date?
    let updated_at: Date?

    var fullName: String { "\(first_name) \(last_name)" }
}
