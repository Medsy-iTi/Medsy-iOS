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

    func fetchOrders(status: String?, page: Int, size: Int) async throws -> PagedResult<OrderEntity> {
        let page = try await remoteDataSource.fetchOrders(page: page, size: size, status: status)
        return OrderMapper.mapToPagedResult(page)
    }

    func fetchOrderDetail(id: Int) async throws -> OrderDetailEntity {
        let order = try await remoteDataSource.fetchOrderDetail(id: id)
        return OrderMapper.mapToDetailEntity(order)
    }
}
