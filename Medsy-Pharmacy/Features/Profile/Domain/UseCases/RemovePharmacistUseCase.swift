//
//  RemovePharmacistUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol RemovePharmacistUseCaseProtocol {
    func execute(pharmacistId: Int, pharmacyId: Int) async throws
}

final class RemovePharmacistUseCase: RemovePharmacistUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pharmacistId: Int, pharmacyId: Int) async throws {
        try await repository.removePharmacist(pharmacistId: pharmacistId, pharmacyId: pharmacyId)
    }
}
