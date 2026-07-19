//
//  CartRepository.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

final class CartRepository: CartRepositoryProtocol {
    private let remoteDataSource: CartRemoteDataSourceProtocol
    private let localDataSource: CartLocalDataSourceProtocol

    init(
        remoteDataSource: CartRemoteDataSourceProtocol,
        localDataSource: CartLocalDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchCachedCart() async throws -> Cart {
        guard let cachedCart = try await localDataSource.fetchCart() else {
            return Cart()
        }
        return CartMapper.map(cachedCart)
    }

    func fetchCart() async throws -> Cart {
        let cart = try await remoteDataSource.fetchCart()
        return try await cacheAndMap(cart)
    }

    func addItem(input: AddCartItemInput) async throws -> Cart {
        let request = AddCartItemRequestDTO(
            productId: input.productID,
            quantity: input.quantity
        )
        let cart = try await remoteDataSource.addItem(request: request)
        return try await cacheAndMap(
            cart,
            dosageByProductID: [input.productID: input.dosageInfo]
        )
    }

    func updateItem(id: Int64, quantity: Int) async throws -> Cart {
        guard quantity > 0 else {
            return try await removeItem(id: id)
        }
        let cart = try await remoteDataSource.updateItem(id: id, quantity: quantity)
        return try await cacheAndMap(cart)
    }

    func removeItem(id: Int64) async throws -> Cart {
        let cart = try await remoteDataSource.removeItem(id: id)
        return try await cacheAndMap(cart)
    }

    func clearCart() async throws {
        try await remoteDataSource.clearCart()
        try await localDataSource.clearCart()
    }

    func fetchItemCount() async throws -> Int {
        try await remoteDataSource.fetchItemCount()
    }

    private func cacheAndMap(
        _ cart: CartDTO,
        dosageByProductID: [Int64: String] = [:]
    ) async throws -> Cart {
        try await localDataSource.saveCart(cart, dosageByProductID: dosageByProductID)
        guard let cachedCart = try await localDataSource.fetchCart() else {
            return CartMapper.map(cart)
        }
        return CartMapper.map(cachedCart)
    }
}
