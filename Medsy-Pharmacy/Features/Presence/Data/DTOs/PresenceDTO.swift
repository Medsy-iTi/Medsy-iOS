//  PresenceDTO.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

struct PresenceResponseDTO: Decodable {
    let lastHeartbeatAt: String
    let onDuty: Bool
}

typealias PresenceEnvelope = APIEnvelope<PresenceResponseDTO>
