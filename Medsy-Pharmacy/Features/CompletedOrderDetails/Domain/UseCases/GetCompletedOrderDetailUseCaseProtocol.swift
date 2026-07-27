//
//  GetCompletedOrderDetailUseCaseProtocol.swift
//  Medsy
//

import Foundation

protocol GetCompletedOrderDetailUseCaseProtocol: AnyObject {
    func execute(id: Int) async throws -> CompletedOrderDetailsEntity
}

final class GetCompletedOrderDetailUseCase: GetCompletedOrderDetailUseCaseProtocol {
    private let repository: CompletedOrderDetailsRepositoryProtocol

    init(repository: CompletedOrderDetailsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> CompletedOrderDetailsEntity {
        try await repository.fetchCompletedOrder(id: id)
    }
}
