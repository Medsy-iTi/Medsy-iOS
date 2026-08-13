//
//  OrdersRepository.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

final class OrdersRepository: OrdersRepositoryProtocol {
    private let remoteDataSource: OrdersRemoteDataSourceProtocol

    init(remoteDataSource: OrdersRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchOrders(filter: OrdersFilter, page: Int, size: Int) async throws -> PagedResult<OrderEntity> {
        let response = try await remoteDataSource.fetchOrders(
            page: page,
            size: size,
            status: filter.exactServerStatus
        )
        return OrderMapper.mapToPagedResult(response)
    }

    func fetchOrderDetail(id: Int) async throws -> OrderDetailEntity {
        let order = try await remoteDataSource.fetchOrderDetail(id: id)
        return OrderMapper.mapToDetailEntity(order)
    }

    func fetchOrderDeliveryLocation(requestID: Int) async throws -> OrderCoordinateEntity {
        let request = try await remoteDataSource.fetchRequestDetail(id: requestID)
        return try OrderMapper.mapDeliveryLocation(request)
    }
}

private extension OrdersFilter {
    var exactServerStatus: String? {
        guard let statuses, statuses.count == 1 else { return nil }
        return statuses[0].rawValue
    }
}
