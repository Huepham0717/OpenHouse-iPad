//
//  UserCreate.swift
//  OpenHouse
//
//  Created by Hue Pham on 8/10/25.
//
import Foundation

// Request
struct UserCreate: Codable {
    let first_name: String
    let last_name: String
    let email: String
    let phone: String
    let note: String?
    let lead_source: String?
}
