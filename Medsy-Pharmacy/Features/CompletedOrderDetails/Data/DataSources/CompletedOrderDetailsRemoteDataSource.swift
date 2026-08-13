//
//  CompletedOrderDetailsRemoteDataSource.swift
//  Medsy
//

import Foundation

protocol CompletedOrderDetailsRemoteDataSourceProtocol {
    func fetchOrder(id: Int) async throws -> CompletedOrderDetailsDTO
    func markOrderReady(id: Int) async throws
    func markOrderOutForDelivery(id: Int) async throws
    func markOrderDelivered(id: Int) async throws
}

final class CompletedOrderDetailsRemoteDataSource: CompletedOrderDetailsRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchOrder(id: Int) async throws -> CompletedOrderDetailsDTO {
        let response: CompletedOrderDetailResponseDTO = try await networkService.request(
            endpoint: CompletedOrderDetailsEndpoint.fetchOrder(id: id)
        )
        return try unwrap(from: response)
    }

    func markOrderReady(id: Int) async throws {
        let response: APIResponseDTO<String> = try await networkService.request(
            endpoint: CompletedOrderDetailsEndpoint.markReady(orderId: id)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }

    func markOrderOutForDelivery(id: Int) async throws {
        let response: APIResponseDTO<String> = try await networkService.request(
            endpoint: CompletedOrderDetailsEndpoint.markOutForDelivery(orderId: id)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }

    func markOrderDelivered(id: Int) async throws {
        let response: APIResponseDTO<String> = try await networkService.request(
            endpoint: CompletedOrderDetailsEndpoint.markDelivered(orderId: id)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }

    private func unwrap(from response: CompletedOrderDetailResponseDTO) throws -> CompletedOrderDetailsDTO {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let order = response.data else {
            throw NetworkError.decodingFailed
        }
        return order
    }
}
