//
//  UpdatePharmacyUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol UpdatePharmacyUseCaseProtocol {
    func execute(input: UpdatePharmacyInput) async throws -> ManagedPharmacy
}

final class UpdatePharmacyUseCase: UpdatePharmacyUseCaseProtocol {
    private let repository: PharmacyManagementRepositoryProtocol

    init(repository: PharmacyManagementRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: UpdatePharmacyInput) async throws -> ManagedPharmacy {
        try await repository.updatePharmacy(input: input)
    }
}
