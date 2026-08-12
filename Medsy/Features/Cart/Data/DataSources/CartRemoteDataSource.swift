//
//  CartRemoteDataSource.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol CartRemoteDataSourceProtocol {
    func fetchCart() async throws -> CartDTO
    func addItem(request: AddCartItemRequestDTO) async throws -> CartDTO
    func updateItem(id: Int64, quantity: Int) async throws -> CartDTO
    func removeItem(id: Int64) async throws -> CartDTO
    func clearCart() async throws
    func fetchItemCount() async throws -> Int
    func fetchInteractions(language: String) async throws -> [CartInteractionWarningDTO]
}

final class CartRemoteDataSource: CartRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchCart() async throws -> CartDTO {
        let response: CartResponseDTO = try await networkService.request(endpoint: CartEndpoint.fetch)
        return try cart(from: response)
    }

    func addItem(request: AddCartItemRequestDTO) async throws -> CartDTO {
        let response: CartResponseDTO = try await networkService.request(endpoint: CartEndpoint.add(request))
        return try cart(from: response)
    }

    func updateItem(id: Int64, quantity: Int) async throws -> CartDTO {
        let response: CartResponseDTO = try await networkService.request(
            endpoint: CartEndpoint.update(itemID: id, quantity: quantity)
        )
        return try cart(from: response)
    }

    func removeItem(id: Int64) async throws -> CartDTO {
        let response: CartResponseDTO = try await networkService.request(
            endpoint: CartEndpoint.remove(itemID: id)
        )
        return try cart(from: response)
    }

    func clearCart() async throws {
        let response: ClearCartResponseDTO = try await networkService.request(endpoint: CartEndpoint.clear)
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }

    func fetchItemCount() async throws -> Int {
        let response: CartCountResponseDTO = try await networkService.request(endpoint: CartEndpoint.count)
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let count = response.data else {
            throw NetworkError.decodingFailed
        }
        return count
    }

    func fetchInteractions(language: String) async throws -> [CartInteractionWarningDTO] {
        let response: CartInteractionsResponseDTO = try await networkService.request(
            endpoint: CartEndpoint.interactions(language: language)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        return response.data?.warnings ?? []
    }

    private func cart(from response: CartResponseDTO) throws -> CartDTO {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let cart = response.data else {
            throw NetworkError.decodingFailed
        }
        return cart
    }
}
