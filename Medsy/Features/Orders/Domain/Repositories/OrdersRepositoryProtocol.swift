//
//  OrdersRepositoryProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

protocol OrdersRepositoryProtocol {
    func fetchOrders(status: String?, page: Int, size: Int) async throws -> PagedResult<OrderEntity>
    func fetchOrderDetail(id: Int) async throws -> OrderDetailEntity
}
