//
//  PharmacyInvitationDTO.swift
//  Medsy-Pharmacy
//

import Foundation

struct InvitePharmacistRequestDTO: Encodable {
    let email: String
}

struct PharmacyInvitationDTO: Decodable {
    let id: Int
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacistId: Int
    let pharmacistFirstName: String
    let pharmacistLastName: String
    let status: String
    let createdAt: String
}

struct PharmacyInvitationEnvelope: Decodable {
    let success: Bool
    let message: String
    let data: PharmacyInvitationDTO
}
