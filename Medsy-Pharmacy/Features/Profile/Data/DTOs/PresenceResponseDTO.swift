//
//  PresenceResponseDTO.swift
//  Medsy-Pharmacy
//

import Foundation

/// Raw API response object for the pharmacist presence endpoints.
struct PresenceResponseDTO: Decodable {
    let onDuty: Bool
    let lastHeartbeatAt: String?
}

/// Top-level envelope wrapping the presence response.
struct PresenceEnvelope: Decodable {
    let success: Bool
    let message: String
    let data: PresenceResponseDTO
}
