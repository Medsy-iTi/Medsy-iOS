//
//  LoadOrdersUseCaseProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

protocol LoadOrdersUseCaseProtocol: AnyObject {
    func execute(filter: OrdersFilter, page: Int, size: Int) async throws -> PagedResult<OrderEntity>
}

final class LoadOrdersUseCase: LoadOrdersUseCaseProtocol {
    private let repository: OrdersRepositoryProtocol

    init(repository: OrdersRepositoryProtocol) {
        self.repository = repository
    }

    func execute(filter: OrdersFilter, page: Int, size: Int) async throws -> PagedResult<OrderEntity> {
        try await repository.fetchOrders(filter: filter, page: page, size: size)
    }
}
