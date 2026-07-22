//
//  SendHeartbeatUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//


import Foundation

protocol SendHeartbeatUseCaseProtocol {
    func execute() async throws -> PresenceStatus
}

final class SendHeartbeatUseCase: SendHeartbeatUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> PresenceStatus {
        try await repository.sendHeartbeat()
    }
}
