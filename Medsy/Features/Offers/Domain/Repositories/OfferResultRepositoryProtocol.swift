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
    func confirmOffer(requestId: Int, selectedItems: [ConfirmSelectedItem]) async throws -> ConfirmOfferResult
    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResult
}
