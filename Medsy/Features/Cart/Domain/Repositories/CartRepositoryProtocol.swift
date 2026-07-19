//
//  CartRepositoryProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol CartRepositoryProtocol {
    func fetchCachedCart() async throws -> Cart
    func fetchCart() async throws -> Cart
    func addItem(input: AddCartItemInput) async throws -> Cart
    func updateItem(id: Int64, quantity: Int) async throws -> Cart
    func removeItem(id: Int64) async throws -> Cart
    func clearCart() async throws
    func fetchItemCount() async throws -> Int
}
