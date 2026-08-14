//
//  CreatePaymentIntentUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

protocol CreatePaymentIntentUseCaseProtocol {
    func execute(masterOrderId: Int) async throws -> PaymentIntent
}

final class CreatePaymentIntentUseCase: CreatePaymentIntentUseCaseProtocol {
    private let repository: PaymentRepositoryProtocol

    init(repository: PaymentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(masterOrderId: Int) async throws -> PaymentIntent {
        try await repository.createPaymentIntent(masterOrderId: masterOrderId)
    }
}
