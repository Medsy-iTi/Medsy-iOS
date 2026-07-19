//
//  CartDTOs.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

typealias CartResponseDTO = APIResponseDTO<CartDTO>
typealias CartCountResponseDTO = APIResponseDTO<Int>
typealias ClearCartResponseDTO = APIResponseDTO<EmptyCartResponseDTO>

struct CartDTO: Decodable, Equatable {
    let id: Int64
    let items: [CartItemDTO]
    let totalPrice: Double
}

struct CartItemDTO: Decodable, Equatable {
    let id: Int64
    let productId: Int64
    let productName: String
    let imageUrl: String?
    let unitPrice: Double
    let quantity: Int
    let subtotal: Double
}

struct AddCartItemRequestDTO: Encodable, Equatable {
    let productId: Int64
    let quantity: Int
}

struct EmptyCartResponseDTO: Decodable, Equatable {}
