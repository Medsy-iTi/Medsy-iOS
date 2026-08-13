//
//  MarkOrderReadyUseCaseProtocol.swift
//  Medsy
//

import Foundation

protocol MarkOrderReadyUseCaseProtocol: AnyObject {
    func execute(id: Int) async throws
}

final class MarkOrderReadyUseCase: MarkOrderReadyUseCaseProtocol {
    private let repository: CompletedOrderDetailsRepositoryProtocol

    init(repository: CompletedOrderDetailsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.markOrderReady(id: id)
    }
}
