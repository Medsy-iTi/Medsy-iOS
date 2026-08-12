//
//  OrdersRemoteDataSource.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

protocol OrdersRemoteDataSourceProtocol {
    func fetchOrders(page: Int, size: Int) async throws -> PageDTO<MasterOrderDTO>
    func fetchOrderDetail(id: Int) async throws -> MasterOrderDTO
}

final class OrdersRemoteDataSource: OrdersRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol
    private let languageProvider: () -> String

    init(
        networkService: NetworkServiceProtocol,
        languageProvider: @escaping () -> String = { LanguageManager.shared.languageCode }
    ) {
        self.networkService = networkService
        self.languageProvider = languageProvider
    }

    func fetchOrders(page: Int, size: Int) async throws -> PageDTO<MasterOrderDTO> {
        let response: OrdersPageResponseDTO = try await networkService.request(
            endpoint: OrdersEndpoint.fetchOrders(
                page: page,
                size: size,
                language: languageProvider()
            )
        )
        return try unwrapPage(from: response)
    }

    func fetchOrderDetail(id: Int) async throws -> MasterOrderDTO {
        let response: OrderDetailResponseDTO = try await networkService.request(
            endpoint: OrdersEndpoint.fetchOrderDetail(id: id, language: languageProvider())
        )
        return try unwrapOrder(from: response)
    }

    private func unwrapPage(from response: OrdersPageResponseDTO) throws -> PageDTO<MasterOrderDTO> {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let page = response.data else {
            throw NetworkError.decodingFailed
        }
        return page
    }

    private func unwrapOrder(from response: OrderDetailResponseDTO) throws -> MasterOrderDTO {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let order = response.data else {
            throw NetworkError.decodingFailed
        }
        return order
    }
}
