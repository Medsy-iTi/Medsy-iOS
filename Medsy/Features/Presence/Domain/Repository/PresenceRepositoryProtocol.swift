//  PresenceRepositoryProtocol.swift
//  Medsy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

protocol PresenceRepositoryProtocol {
    func sendHeartbeat() async throws -> PresenceEntity
}
