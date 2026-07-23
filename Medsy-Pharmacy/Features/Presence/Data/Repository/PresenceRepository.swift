//  PresenceRepository.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

final class PresenceRepository: PresenceRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func goOnDuty() async throws -> PresenceEntity {
        let envelope: PresenceEnvelope = try await networkService.request(endpoint: PresenceEndpoint.goOnDuty)
        return map(envelope)
    }

    func goOffDuty() async throws -> PresenceEntity {
        let envelope: PresenceEnvelope = try await networkService.request(endpoint: PresenceEndpoint.goOffDuty)
        return map(envelope)
    }

    func sendHeartbeat() async throws -> PresenceEntity {
        let envelope: PresenceEnvelope = try await networkService.request(endpoint: PresenceEndpoint.heartbeat)
        return map(envelope)
    }

    private func map(_ envelope: PresenceEnvelope) -> PresenceEntity {
        let dto = envelope.data
        return PresenceEntity(
            lastHeartbeatAt: dto?.lastHeartbeatAt ?? "",
            onDuty: dto?.onDuty ?? false
        )
    }
}
