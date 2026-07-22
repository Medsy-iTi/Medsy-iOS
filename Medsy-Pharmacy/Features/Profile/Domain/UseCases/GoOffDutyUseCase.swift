//
//  GoOffDutyUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//



import Foundation

protocol GoOffDutyUseCaseProtocol {
    func execute() async throws -> PresenceStatus
}

final class GoOffDutyUseCase: GoOffDutyUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> PresenceStatus {
        try await repository.goOffDuty()
    }
}
