//
//  ConfirmOfferUseCase.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol ConfirmOfferUseCaseProtocol {
    func execute(requestId: Int, selections: [ConfirmOfferSelection]) async throws -> ConfirmOfferResult
}

final class ConfirmOfferUseCase: ConfirmOfferUseCaseProtocol {
    private let repository: OfferResultRepositoryProtocol

    init(repository: OfferResultRepositoryProtocol) {
        self.repository = repository
    }

    func execute(requestId: Int, selections: [ConfirmOfferSelection]) async throws -> ConfirmOfferResult {
        try await repository.confirmOffer(requestId: requestId, selections: selections)
    }
}
