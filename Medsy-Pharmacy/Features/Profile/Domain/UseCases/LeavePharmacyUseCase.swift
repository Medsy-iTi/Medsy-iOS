//
//  LeavePharmacyUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol LeavePharmacyUseCaseProtocol {
    func execute(pharmacyId: Int) async throws
}

final class LeavePharmacyUseCase: LeavePharmacyUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pharmacyId: Int) async throws {
        try await repository.leavePharmacy(pharmacyId: pharmacyId)
    }
}
