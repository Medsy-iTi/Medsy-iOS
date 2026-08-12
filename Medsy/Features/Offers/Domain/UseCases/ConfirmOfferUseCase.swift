//
//  ConfirmOfferUseCase.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol ConfirmOfferUseCaseProtocol {
    func selectPharmacy(requestId: Int, selectedItems: [ConfirmSelectedItem]) async throws -> SelectPharmacyResponseDTO
    func selectPharmacy(requestId: Int, selectedRequestItemIds: [Int]) async throws -> SelectPharmacyResponseDTO
    func confirmOffer(requestId: Int, fulfillmentMethod: String) async throws -> ConfirmOfferResult
}

final class ConfirmOfferUseCase: ConfirmOfferUseCaseProtocol {
    private let repository: OfferResultRepositoryProtocol

    init(repository: OfferResultRepositoryProtocol) {
        self.repository = repository
    }

    func selectPharmacy(requestId: Int, selectedItems: [ConfirmSelectedItem]) async throws -> SelectPharmacyResponseDTO {
        try await repository.selectPharmacy(requestId: requestId, selectedItems: selectedItems)
    }

    func selectPharmacy(requestId: Int, selectedRequestItemIds: [Int]) async throws -> SelectPharmacyResponseDTO {
        try await repository.selectPharmacy(requestId: requestId, selectedRequestItemIds: selectedRequestItemIds)
    }

    func confirmOffer(requestId: Int, fulfillmentMethod: String) async throws -> ConfirmOfferResult {
        try await repository.confirmOffer(requestId: requestId, fulfillmentMethod: fulfillmentMethod)
    }
}
