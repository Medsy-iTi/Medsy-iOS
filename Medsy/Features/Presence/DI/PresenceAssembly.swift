//  PresenceAssembly.swift
//  Medsy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

struct PresenceAssembly: ModuleAssembly {
    @MainActor
    func register(in container: DIContainer) {
        container.register(PresenceRepositoryProtocol.self) { container in
            PresenceRepository(networkService: container.resolve(NetworkServiceProtocol.self))
        }

        container.register(SendHeartbeatUseCaseProtocol.self) { container in
            SendHeartbeatUseCase(repository: container.resolve(PresenceRepositoryProtocol.self))
        }

        container.register(HeartbeatService.self) { container in
            HeartbeatService(sendHeartbeatUseCase: container.resolve(SendHeartbeatUseCaseProtocol.self))
        }
    }
}
