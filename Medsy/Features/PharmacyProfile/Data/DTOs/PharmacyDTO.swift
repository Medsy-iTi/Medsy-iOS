//
//  PharmacyDTO.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation

struct PharmacyResponseDTO: Codable, Sendable {
    let success: Bool
    let message: String
    let data: PharmacyDataDTO
}

struct PharmacyDataDTO: Codable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String
    let phoneNumber: String
}
