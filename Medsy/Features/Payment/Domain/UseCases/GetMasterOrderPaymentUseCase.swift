//
//  GetMasterOrderPaymentUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

protocol GetMasterOrderPaymentUseCaseProtocol {
    func execute(masterOrderId: Int) async throws -> MasterOrderPayment
}

final class GetMasterOrderPaymentUseCase: GetMasterOrderPaymentUseCaseProtocol {
    private let repository: PaymentRepositoryProtocol

    init(repository: PaymentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(masterOrderId: Int) async throws -> MasterOrderPayment {
        try await repository.fetchMasterOrderPayment(masterOrderId: masterOrderId)
    }
}
