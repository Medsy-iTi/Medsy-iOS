//
//  SendOfferUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol SendOfferUseCaseProtocol: Sendable {
    func execute(requestId: Int, items: [(requestItemId: Int, productId: Int)]) async throws -> Bool
}

final class SendOfferUseCase: SendOfferUseCaseProtocol {
    private let repository: PharmacyRequestsRepositoryProtocol

    init(repository: PharmacyRequestsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(requestId: Int, items: [(requestItemId: Int, productId: Int)]) async throws -> Bool {
        try await repository.sendOffer(requestId: requestId, items: items)
    }
}
