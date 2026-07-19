//
//  DeletePharmacyUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol DeletePharmacyUseCaseProtocol {
    func execute(id: Int) async throws
}

final class DeletePharmacyUseCase: DeletePharmacyUseCaseProtocol {
    private let repository: PharmacyManagementRepositoryProtocol

    init(repository: PharmacyManagementRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.deletePharmacy(id: id)
    }
}
