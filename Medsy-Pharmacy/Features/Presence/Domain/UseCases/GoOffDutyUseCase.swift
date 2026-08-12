//  GoOffDutyUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

protocol GoOffDutyUseCaseProtocol {
    func execute() async throws -> PresenceEntity
}

struct GoOffDutyUseCase: GoOffDutyUseCaseProtocol {
    let repository: PresenceRepositoryProtocol

    func execute() async throws -> PresenceEntity {
        try await repository.goOffDuty()
    }
}
