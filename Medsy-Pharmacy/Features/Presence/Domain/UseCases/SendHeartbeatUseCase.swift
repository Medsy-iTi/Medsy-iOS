//  SendHeartbeatUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

protocol SendHeartbeatUseCaseProtocol {
    func execute() async throws -> PresenceEntity
}

struct SendHeartbeatUseCase: SendHeartbeatUseCaseProtocol {
    let repository: PresenceRepositoryProtocol

    func execute() async throws -> PresenceEntity {
        try await repository.sendHeartbeat()
    }
}
