//
//  MarkOrderOutForDeliveryUseCaseProtocol.swift
//  Medsy
//

import Foundation

protocol MarkOrderOutForDeliveryUseCaseProtocol: AnyObject {
    func execute(id: Int) async throws
}

final class MarkOrderOutForDeliveryUseCase: MarkOrderOutForDeliveryUseCaseProtocol {
    private let repository: CompletedOrderDetailsRepositoryProtocol

    init(repository: CompletedOrderDetailsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.markOrderOutForDelivery(id: id)
    }
}
