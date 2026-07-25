//  PresenceRepository.swift
//  Medsy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

final class PresenceRepository: PresenceRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func sendHeartbeat() async throws -> PresenceEntity {
        let envelope: PresenceEnvelope = try await networkService.request(endpoint: PresenceEndpoint.heartbeat)
        let dto = envelope.data
        return PresenceEntity(
            lastHeartbeatAt: dto?.lastHeartbeatAt ?? "",
            onDuty: dto?.onDuty ?? false
        )
    }
}
