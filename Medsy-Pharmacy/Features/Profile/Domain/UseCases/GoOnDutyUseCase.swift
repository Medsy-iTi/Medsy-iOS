//
//  GoOnDutyUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol GoOnDutyUseCaseProtocol {
    /// Marks the authenticated pharmacist as on-duty.
    /// - Returns: The updated `PresenceStatus` from the server.
    func execute() async throws -> PresenceStatus
}

struct GoOnDutyUseCase: GoOnDutyUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> PresenceStatus {
        try await repository.goOnDuty()
    }
}
