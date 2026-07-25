//
//  OrdersRepository.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

final class OrdersRepository: OrdersRepositoryProtocol {
    private let remoteDataSource: OrdersRemoteDataSourceProtocol
    private let isoDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init(remoteDataSource: OrdersRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchOrders(filter: OrdersFilter, page: Int, size: Int) async throws -> PagedResult<OrderEntity> {
        let statusParam = filter.statuses.map { $0.map(\.rawValue).joined(separator: ",") }
        let dateFromParam = filter.dateFrom.map { isoDateFormatter.string(from: $0) }
        let dateToParam = filter.dateTo.map { isoDateFormatter.string(from: $0) }
        let page = try await remoteDataSource.fetchOrders(
            page: page,
            size: size,
            status: statusParam,
            dateFrom: dateFromParam,
            dateTo: dateToParam
        )
        return OrderMapper.mapToPagedResult(page)
    }

    func fetchOrderDetail(id: Int) async throws -> OrderDetailEntity {
        let order = try await remoteDataSource.fetchOrderDetail(id: id)
        return OrderMapper.mapToDetailEntity(order)
    }
}

