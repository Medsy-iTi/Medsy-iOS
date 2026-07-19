//
//  PharmacyProfileDTO.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

struct PharmacyProfileDTO: Decodable {
    let id: String
    let name: String
    let isVerified: Bool
    let rating: Double
    let ratingCount: Int
    let avatarURL: String?

    let phoneNumber: String
    let licenseSummary: String
    let registeredAddress: String

    let isAcceptingOrders: Bool
    let language: String
    let isDarkModeEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isVerified = "is_verified"
        case rating
        case ratingCount = "rating_count"
        case avatarURL = "avatar_url"
        case phoneNumber = "phone_number"
        case licenseSummary = "license_summary"
        case registeredAddress = "registered_address"
        case isAcceptingOrders = "is_accepting_orders"
        case language
        case isDarkModeEnabled = "is_dark_mode_enabled"
    }
}

struct UpdateOrderReceivingStatusResponseDTO: Decodable {
    let isAcceptingOrders: Bool

    enum CodingKeys: String, CodingKey {
        case isAcceptingOrders = "is_accepting_orders"
    }
}
