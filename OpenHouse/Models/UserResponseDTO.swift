//
//  UserResponseDTO.swift
//  OpenHouse
//
//  Created by Hue Pham on 8/10/25.
//
import Foundation

// Response
struct UserResponseDTO: Codable {
    let id: Int
    let first_name: String
    let last_name: String
    let email: String
    let phone: String
    let note: String?
    let created_at: String?
    let updated_at: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}
