//
//  OrdersRemoteDataSource.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

protocol OrdersRemoteDataSourceProtocol {
    func fetchOrders(page: Int, size: Int) async throws -> PageDTO<OrderDTO>
    func fetchOrderDetail(id: Int) async throws -> OrderDTO
}

final class OrdersRemoteDataSource: OrdersRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchOrders(page: Int, size: Int) async throws -> PageDTO<OrderDTO> {
        let response: OrdersPageResponseDTO = try await networkService.request(
            endpoint: OrdersEndpoint.fetchOrders(page: page, size: size)
        )
        return try unwrapPage(from: response)
    }

    func fetchOrderDetail(id: Int) async throws -> OrderDTO {
        let response: OrderDetailResponseDTO = try await networkService.request(
            endpoint: OrdersEndpoint.fetchOrderDetail(id: id)
        )
        return try unwrapOrder(from: response)
    }

    private func unwrapPage(from response: OrdersPageResponseDTO) throws -> PageDTO<OrderDTO> {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let page = response.data else {
            throw NetworkError.decodingFailed
        }
        return page
    }

    private func unwrapOrder(from response: OrderDetailResponseDTO) throws -> OrderDTO {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let order = response.data else {
            throw NetworkError.decodingFailed
        }
        return order
    }
}
