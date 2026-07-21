//
//  GetOrderDetailUseCaseProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

protocol GetOrderDetailUseCaseProtocol: AnyObject {
    func execute(id: Int) async throws -> OrderDetailEntity
}

final class GetOrderDetailUseCase: GetOrderDetailUseCaseProtocol {
    private let repository: OrdersRepositoryProtocol

    init(repository: OrdersRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> OrderDetailEntity {
        try await repository.fetchOrderDetail(id: id)
    }
}
