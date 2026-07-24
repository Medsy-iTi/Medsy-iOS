//  PresenceRepositoryProtocol.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

protocol PresenceRepositoryProtocol {
    func goOnDuty() async throws -> PresenceEntity
    func goOffDuty() async throws -> PresenceEntity
    func sendHeartbeat() async throws -> PresenceEntity
}
