//
//  GoOffDutyUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol GoOffDutyUseCaseProtocol {
    /// Marks the authenticated pharmacist as off-duty.
    /// - Returns: The updated `PresenceStatus` from the server.
    func execute() async throws -> PresenceStatus
}

struct GoOffDutyUseCase: GoOffDutyUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> PresenceStatus {
        try await repository.goOffDuty()
    }
}
