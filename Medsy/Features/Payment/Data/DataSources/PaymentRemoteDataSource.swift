//
//  PaymentRemoteDataSource.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

protocol PaymentRemoteDataSourceProtocol {
    func fetchMasterOrderPayment(masterOrderId: Int) async throws -> MasterOrderPaymentDTO
    func createPaymentIntent(masterOrderId: Int) async throws -> PaymentIntentDTO
}

final class PaymentRemoteDataSource: PaymentRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchMasterOrderPayment(masterOrderId: Int) async throws -> MasterOrderPaymentDTO {
        let response: MasterOrderPaymentResponseDTO = try await networkService.request(
            endpoint: PaymentEndpoint.fetchMasterOrder(id: masterOrderId)
        )
        return try unwrap(response)
    }

    func createPaymentIntent(masterOrderId: Int) async throws -> PaymentIntentDTO {
        let response: PaymentIntentResponseDTO = try await networkService.request(
            endpoint: PaymentEndpoint.createIntent(
                CreatePaymentIntentRequestDTO(orderId: masterOrderId)
            )
        )
        return try unwrap(response)
    }

    private func unwrap<T>(_ response: APIResponseDTO<T>) throws -> T {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }
}
