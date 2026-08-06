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

    func streamOfferResult(requestId: Int) -> AsyncThrowingStream<OfferResult, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let stream = remoteDataSource.streamOfferResult(requestId: requestId)
                    for try await dto in stream {
                        if Task.isCancelled { break }
                        let domainModel = OfferResultMapper.map(dto)
                        continuation.yield(domainModel)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResult {
        let dto = try await remoteDataSource.confirmOffer(
            requestId: requestId,
            selectedRequestItemIds: selectedRequestItemIds
        )
        return OfferResultMapper.map(dto)
    }
}
