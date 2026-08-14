//
//  MarkOrderDeliveredUseCaseProtocol.swift
//  Medsy
//

import Foundation

protocol MarkOrderDeliveredUseCaseProtocol: AnyObject {
    func execute(id: Int) async throws
}

final class MarkOrderDeliveredUseCase: MarkOrderDeliveredUseCaseProtocol {
    private let repository: CompletedOrderDetailsRepositoryProtocol

    init(repository: CompletedOrderDetailsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.markOrderDelivered(id: id)
    }
}
