//
//  OrdersRepositoryProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

protocol OrdersRepositoryProtocol {
    func fetchOrders(filter: OrdersFilter, page: Int, size: Int) async throws -> PagedResult<OrderEntity>
    func fetchOrderDetail(id: Int) async throws -> OrderDetailEntity
    func fetchOrderDeliveryLocation(requestID: Int) async throws -> OrderCoordinateEntity
}
