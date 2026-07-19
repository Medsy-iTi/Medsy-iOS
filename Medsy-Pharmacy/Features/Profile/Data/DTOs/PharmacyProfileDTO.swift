//
//  PharmacyProfileDTO.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation


struct PharmacistResponseDTO: Decodable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let pharmacyId: Int?
    let pharmacyAdmin: Bool
    let homeAddress: String?
    let dob: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName
        case lastName
        case phoneNumber
        case pharmacyId
        case pharmacyAdmin
        case homeAddress
        case dob
    }
}


struct PharmacistMeResponseEnvelope: Decodable {
    let success: Bool
    let message: String
    let data: PharmacistResponseDTO
}


struct PharmacistMemberDTO: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let isAdmin: Bool
}

struct PharmacyMineResponseDTO: Decodable {
    let id: Int
    let name: String
    let address: String?
    let phoneNumber: String?
    let isAdmin: Bool
    let pharmacists: [PharmacistMemberDTO]?

    enum CodingKeys: String, CodingKey {
        case id, name, address, phoneNumber, isAdmin, pharmacists
    }
}

struct PharmacyMineEnvelope: Decodable {
    let success: Bool
    let message: String
    let data: PharmacyMineResponseDTO
}

struct UpdateOrderReceivingStatusResponseDTO: Decodable {
    let isAcceptingOrders: Bool

    enum CodingKeys: String, CodingKey {
        case isAcceptingOrders = "is_accepting_orders"
    }
}
