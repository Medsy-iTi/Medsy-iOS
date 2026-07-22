//
//  PresenceStatusDTO.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//


//
//  PresenceDTO.swift
//  Medsy-Pharmacy
//

import Foundation

struct PresenceStatusDTO: Decodable {
    let onDuty: Bool
    let lastHeartbeatAt: String
}

struct PresenceEnvelope: Decodable {
    let success: Bool
    let message: String
    let data: PresenceStatusDTO
}