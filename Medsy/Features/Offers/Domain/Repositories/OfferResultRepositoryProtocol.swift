//
//  OfferResultRepositoryProtocol.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol OfferResultRepositoryProtocol {
    func getOfferResult(requestId: Int) async throws -> OfferResult
    func streamOfferResult(requestId: Int) -> AsyncThrowingStream<OfferResult, Error>
    func selectPharmacy(requestId: Int, selectedItems: [ConfirmSelectedItem]) async throws -> SelectPharmacyResponseDTO
    func selectPharmacy(requestId: Int, selectedRequestItemIds: [Int]) async throws -> SelectPharmacyResponseDTO
    func confirmOffer(requestId: Int, fulfillmentMethod: String) async throws -> ConfirmOfferResult
}
