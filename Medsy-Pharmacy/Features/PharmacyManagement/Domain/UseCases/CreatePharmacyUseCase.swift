//
//  CreatePharmacyUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol CreatePharmacyUseCaseProtocol {
    func execute(input: CreatePharmacyInput) async throws -> ManagedPharmacy
}

final class CreatePharmacyUseCase: CreatePharmacyUseCaseProtocol {
    private let repository: PharmacyManagementRepositoryProtocol

    init(repository: PharmacyManagementRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: CreatePharmacyInput) async throws -> ManagedPharmacy {
        try await repository.createPharmacy(input: input)
    }
}
