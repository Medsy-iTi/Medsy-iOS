//
//  DeletePharmacyUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol DeletePharmacyUseCaseProtocol {
    func execute(id: Int) async throws
}

final class DeletePharmacyUseCase: DeletePharmacyUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.deletePharmacy(id: id)
    }
}
