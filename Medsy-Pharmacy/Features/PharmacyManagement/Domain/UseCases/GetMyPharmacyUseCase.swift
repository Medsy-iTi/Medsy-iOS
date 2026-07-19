//
//  GetMyPharmacyUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol GetMyPharmacyUseCaseProtocol {
    func execute() async throws -> ManagedPharmacy?
}

final class GetMyPharmacyUseCase: GetMyPharmacyUseCaseProtocol {
    private let repository: PharmacyManagementRepositoryProtocol

    init(repository: PharmacyManagementRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ManagedPharmacy? {
        try await repository.getMyPharmacy()
    }
}
