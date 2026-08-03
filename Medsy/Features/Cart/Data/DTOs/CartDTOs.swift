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

    private enum CodingKeys: String, CodingKey {
        case id
        case productId
        case productName
        case imageUrl
        case unitPrice
        case quantity
        case subtotal
        case product
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let product = try container.decodeIfPresent(CartItemProductDTO.self, forKey: .product)

        id = try container.decode(Int64.self, forKey: .id)
        productId = try container.decodeIfPresent(Int64.self, forKey: .productId)
            ?? product?.id
            ?? 0
        productName = try container.decodeIfPresent(String.self, forKey: .productName)
            ?? product?.productName
            ?? product?.name
            ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            ?? product?.imageUrl
        unitPrice = try container.decodeIfPresent(Double.self, forKey: .unitPrice) ?? 0
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 0
        subtotal = try container.decodeIfPresent(Double.self, forKey: .subtotal)
            ?? unitPrice * Double(quantity)
    }
}

private struct CartItemProductDTO: Decodable {
    let id: Int64?
    let name: String?
    let productName: String?
    let imageUrl: String?
}

struct AddCartItemRequestDTO: Encodable, Equatable {
    let productId: Int64
    let quantity: Int
}

struct EmptyCartResponseDTO: Decodable, Equatable {}

struct CachedCartPrescriptionDTO: Equatable {
    let id: UUID
    let data: Data
    let source: CartPrescriptionSource
    let createdAt: Date
}

struct CachedCartDTO: Equatable {
    let id: Int64
    let items: [CachedCartItemDTO]
    let totalPrice: Double
}

struct CachedCartItemDTO: Equatable {
    let id: Int64
    let productId: Int64
    let productName: String
    let dosageInfo: String
    let imageUrl: String?
    let unitPrice: Double
    let quantity: Int
    let subtotal: Double
}
