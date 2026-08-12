//
//  GetOfferResultUseCase.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol GetOfferResultUseCaseProtocol {
    func execute(requestId: Int) async throws -> OfferResult
}

final class GetOfferResultUseCase: GetOfferResultUseCaseProtocol {
    private let repository: OfferResultRepositoryProtocol

    init(repository: OfferResultRepositoryProtocol) {
        self.repository = repository
    }

    func execute(requestId: Int) async throws -> OfferResult {
        try await repository.getOfferResult(requestId: requestId)
    }
}
