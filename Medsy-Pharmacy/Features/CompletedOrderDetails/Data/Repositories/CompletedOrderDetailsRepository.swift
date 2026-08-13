//
//  CompletedOrderDetailsRepository.swift
//  Medsy
//

import Foundation

final class CompletedOrderDetailsRepository: CompletedOrderDetailsRepositoryProtocol {
    private let remoteDataSource: CompletedOrderDetailsRemoteDataSourceProtocol

    init(remoteDataSource: CompletedOrderDetailsRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchCompletedOrder(id: Int) async throws -> CompletedOrderDetailsEntity {
        let dto = try await remoteDataSource.fetchOrder(id: id)
        return CompletedOrderDetailsMapper.mapToEntity(dto)
    }

    func markOrderReady(id: Int) async throws {
        try await remoteDataSource.markOrderReady(id: id)
    }

    func markOrderOutForDelivery(id: Int) async throws {
        try await remoteDataSource.markOrderOutForDelivery(id: id)
    }

    func markOrderDelivered(id: Int) async throws {
        try await remoteDataSource.markOrderDelivered(id: id)
    }
}
