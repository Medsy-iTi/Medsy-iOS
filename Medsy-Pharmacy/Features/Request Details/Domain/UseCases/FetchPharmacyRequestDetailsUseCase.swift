//  FetchPharmacyRequestDetailsUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

protocol FetchPharmacyRequestDetailsUseCaseProtocol {
    func execute(requestId: Int) async throws -> PharmacyRequestDetailsEntity
}

struct FetchPharmacyRequestDetailsUseCase: FetchPharmacyRequestDetailsUseCaseProtocol {
    let repository: PharmacyRequestDetailsRepositoryProtocol

    func execute(requestId: Int) async throws -> PharmacyRequestDetailsEntity {
        try await repository.fetchRequestDetails(requestId: requestId)
    }
}
