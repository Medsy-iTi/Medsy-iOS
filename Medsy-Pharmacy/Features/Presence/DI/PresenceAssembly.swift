//  PresenceAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

struct PresenceAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PresenceRepositoryProtocol.self) { container in
            PresenceRepository(networkService: container.resolve(NetworkServiceProtocol.self))
        }

        container.register(GoOnDutyUseCaseProtocol.self) { container in
            GoOnDutyUseCase(repository: container.resolve(PresenceRepositoryProtocol.self))
        }

        container.register(GoOffDutyUseCaseProtocol.self) { container in
            GoOffDutyUseCase(repository: container.resolve(PresenceRepositoryProtocol.self))
        }

        container.register(SendHeartbeatUseCaseProtocol.self) { container in
            SendHeartbeatUseCase(repository: container.resolve(PresenceRepositoryProtocol.self))
        }

        container.register(PharmacyHeartbeatService.self) { container in
            PharmacyHeartbeatService(sendHeartbeatUseCase: container.resolve(SendHeartbeatUseCaseProtocol.self))
        }

        container.register(DutyStatusStore.self) { _ in
            DutyStatusStore()
        }
    }
}
