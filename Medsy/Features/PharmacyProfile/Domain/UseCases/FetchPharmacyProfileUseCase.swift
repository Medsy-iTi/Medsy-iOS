//
//  FetchPharmacyProfileUseCase.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation

protocol FetchPharmacyProfileUseCaseProtocol {
    func execute(id: Int) async throws -> Pharmacy
}

final class FetchPharmacyProfileUseCase: FetchPharmacyProfileUseCaseProtocol {
    private let repository: PharmacyRepositoryProtocol

    init(repository: PharmacyRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Pharmacy {
        try await repository.fetchPharmacy(id: id)
    }
}
