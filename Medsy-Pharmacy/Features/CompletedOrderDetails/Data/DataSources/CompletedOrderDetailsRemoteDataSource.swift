//
//  CompletedOrderDetailsRemoteDataSource.swift
//  Medsy
//

import Foundation

protocol CompletedOrderDetailsRemoteDataSourceProtocol {
    func fetchOrder(id: Int) async throws -> CompletedOrderDetailsDTO
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
