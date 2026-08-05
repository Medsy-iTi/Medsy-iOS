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
typealias CartInteractionsResponseDTO = APIResponseDTO<CartInteractionsDTO>

struct CartInteractionsDTO: Decodable, Equatable {
    let warnings: [CartInteractionWarningDTO]

    private enum CodingKeys: String, CodingKey {
        case warnings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        warnings = try container.decodeIfPresent([CartInteractionWarningDTO].self, forKey: .warnings) ?? []
    }
}

struct CartInteractionWarningDTO: Decodable, Equatable {
    let severity: String
    let title: String
    let advice: String
    let involvedProducts: [CartInteractionProductDTO]

    private enum CodingKeys: String, CodingKey {
        case severity
        case title
        case advice
        case involvedProducts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        severity = try container.decodeIfPresent(String.self, forKey: .severity) ?? "MODERATE"
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        advice = try container.decodeIfPresent(String.self, forKey: .advice) ?? ""
        involvedProducts = try container.decodeIfPresent(
            [CartInteractionProductDTO].self,
            forKey: .involvedProducts
        ) ?? []
    }
}

struct CartInteractionProductDTO: Decodable, Equatable {
    let productId: Int64
    let productName: String
    let ingredient: String

    private enum CodingKeys: String, CodingKey {
        case productId
        case productName
        case ingredient
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try container.decode(Int64.self, forKey: .productId)
        productName = try container.decodeIfPresent(String.self, forKey: .productName) ?? ""
        ingredient = try container.decodeIfPresent(String.self, forKey: .ingredient) ?? ""
    }
}

struct CartDTO: Decodable, Equatable {
    let id: Int64
    let items: [CartItemDTO]
    let totalPrice: Double

    private enum CodingKeys: String, CodingKey {
        case id
        case items
        case totalPrice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        items = try container.decodeIfPresent([CartItemDTO].self, forKey: .items) ?? []
        totalPrice = try container.decodeIfPresent(Double.self, forKey: .totalPrice)
            ?? items.reduce(0) { $0 + $1.subtotal }
    }
}

struct CartItemDTO: Decodable, Equatable {
    let id: Int64
    let productId: Int64
    let productName: String
    let dosageInfo: String
    let imageUrl: String?
    let unitPrice: Double
    let quantity: Int
    let subtotal: Double

    private enum CodingKeys: String, CodingKey {
        case id
        case productId
        case productName
        case dosageInfo
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
            ?? Self.missingProductID(in: container)
        productName = try container.decodeIfPresent(String.self, forKey: .productName)
            ?? product?.displayName
            ?? ""
        dosageInfo = try container.decodeIfPresent(String.self, forKey: .dosageInfo)
            ?? product?.dosageInfo
            ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            ?? product?.imageUrl
        unitPrice = try container.decodeIfPresent(Double.self, forKey: .unitPrice)
            ?? product?.price
            ?? 0
        quantity = try container.decode(Int.self, forKey: .quantity)
        subtotal = try container.decodeIfPresent(Double.self, forKey: .subtotal)
            ?? unitPrice * Double(quantity)
    }

    private static func missingProductID(
        in container: KeyedDecodingContainer<CodingKeys>
    ) throws -> Int64 {
        throw DecodingError.dataCorruptedError(
            forKey: .productId,
            in: container,
            debugDescription: "Cart item is missing its product identifier."
        )
    }
}

private struct CartItemProductDTO: Decodable {
    let id: Int64?
    let name: String?
    let productName: String?
    let strength: String?
    let packSize: String?
    let form: String?
    let price: Double?
    let imageUrl: String?

    var displayName: String? {
        [productName, name]
            .compactMap(Self.nonEmpty)
            .first
    }

    var dosageInfo: String? {
        let details = [strength, packSize]
            .compactMap(Self.nonEmpty)
        if !details.isEmpty {
            return details.joined(separator: " • ")
        }
        return Self.nonEmpty(form)
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }
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
