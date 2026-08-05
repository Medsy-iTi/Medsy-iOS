//
//  FetchPharmacyRequestsUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol FetchPharmacyRequestsUseCaseProtocol: Sendable {
    func execute(page: Int, size: Int) async throws -> [PharmacyMedicineRequestEntity]
    func execute(requestId: Int) async throws -> PharmacyMedicineRequestEntity
}

final class FetchPharmacyRequestsUseCase: FetchPharmacyRequestsUseCaseProtocol {
    private let repository: PharmacyRequestsRepositoryProtocol

    init(repository: PharmacyRequestsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, size: Int) async throws -> [PharmacyMedicineRequestEntity] {
        try await repository.fetchRequests(page: page, size: size)
    }

    func execute(requestId: Int) async throws -> PharmacyMedicineRequestEntity {
        try await repository.fetchRequestById(requestId: requestId)
    }
}
