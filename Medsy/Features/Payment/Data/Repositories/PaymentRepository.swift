//
//  PaymentRepository.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

final class PaymentRepository: PaymentRepositoryProtocol {
    private let remoteDataSource: PaymentRemoteDataSourceProtocol

    init(remoteDataSource: PaymentRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchMasterOrderPayment(masterOrderId: Int) async throws -> MasterOrderPayment {
        let dto = try await remoteDataSource.fetchMasterOrderPayment(masterOrderId: masterOrderId)
        return PaymentMapper.map(dto)
    }

    func createPaymentIntent(masterOrderId: Int) async throws -> PaymentIntent {
        let dto = try await remoteDataSource.createPaymentIntent(masterOrderId: masterOrderId)
        return PaymentMapper.map(dto)
    }
}
