//
//  GetCompletedOrdersUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import Foundation

protocol GetCompletedOrdersUseCaseProtocol {
    func execute(
        pharmacyId: Int,
        page: Int,
        size: Int,
        sort: [String]
    ) async throws -> PaginatedResult<CompletedOrder>
}

struct GetCompletedOrdersUseCase: GetCompletedOrdersUseCaseProtocol {
    private let repository: CompletedOrdersRepositoryProtocol

    init(repository: CompletedOrdersRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        pharmacyId: Int,
        page: Int = 0,
        size: Int = 20,
        sort: [String] = []
    ) async throws -> PaginatedResult<CompletedOrder> {
        try await repository.fetchOrders(pharmacyId: pharmacyId, page: page, size: size, sort: sort)
    }
}
