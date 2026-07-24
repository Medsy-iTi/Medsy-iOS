//
//  GetCartItemCountUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol GetCartItemCountUseCaseProtocol {
    func execute() async throws -> Int
}

final class GetCartItemCountUseCase: GetCartItemCountUseCaseProtocol {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> Int {
        try await repository.fetchItemCount()
    }
}
