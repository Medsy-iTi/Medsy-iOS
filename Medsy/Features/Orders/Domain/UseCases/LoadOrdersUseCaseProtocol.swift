//
//  LoadOrdersUseCaseProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

protocol LoadOrdersUseCaseProtocol: AnyObject {
    func execute(statuses: [OrderStatus]?, page: Int, size: Int) async throws -> PagedResult<OrderEntity>
}

final class LoadOrdersUseCase: LoadOrdersUseCaseProtocol {
    private let repository: OrdersRepositoryProtocol

    init(repository: OrdersRepositoryProtocol) {
        self.repository = repository
    }

    func execute(statuses: [OrderStatus]?, page: Int, size: Int) async throws -> PagedResult<OrderEntity> {
        let statusParam = statuses.map { $0.map(\.rawValue).joined(separator: ",") }
        return try await repository.fetchOrders(status: statusParam, page: page, size: size)
    }
}
