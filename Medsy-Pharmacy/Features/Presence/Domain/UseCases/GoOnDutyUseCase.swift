//  GoOnDutyUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

protocol GoOnDutyUseCaseProtocol {
    func execute() async throws -> PresenceEntity
}

struct GoOnDutyUseCase: GoOnDutyUseCaseProtocol {
    let repository: PresenceRepositoryProtocol

    func execute() async throws -> PresenceEntity {
        try await repository.goOnDuty()
    }
}
