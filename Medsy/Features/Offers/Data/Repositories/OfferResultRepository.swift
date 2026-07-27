//
//  OfferResultRepository.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

final class OfferResultRepository: OfferResultRepositoryProtocol {
    private let remoteDataSource: OffersRemoteDataSourceProtocol

    init(remoteDataSource: OffersRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func getOfferResult(requestId: Int) async throws -> OfferResult {
        let dto = try await remoteDataSource.getOfferResult(requestId: requestId)
        return OfferResultMapper.map(dto)
    }

    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResult {
        let dto = try await remoteDataSource.confirmOffer(
            requestId: requestId,
            selectedRequestItemIds: selectedRequestItemIds
        )
        return OfferResultMapper.map(dto)
    }
}
