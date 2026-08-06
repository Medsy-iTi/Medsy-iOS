//
//  OfferResultDTOs.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

typealias GetOfferResultResponseDTO = APIResponseDTO<OfferResultResponseDTO>
typealias ConfirmOfferResponseDTOContainer = APIResponseDTO<ConfirmOfferResponseDTO>

struct OfferResultResponseDTO: Decodable, Equatable {
    let items: [OfferResultItemDTO]
    let totalPrice: Double
    let prescriptionUrl: String?

    private enum CodingKeys: String, CodingKey {
        case items = "medicineRequestResultItemList"
        case fallbackItems = "items"
        case totalPrice
        case prescriptionUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let itemsList = try container.decodeIfPresent([OfferResultItemDTO].self, forKey: .items) {
            items = itemsList
        } else if let fallback = try container.decodeIfPresent([OfferResultItemDTO].self, forKey: .fallbackItems) {
            items = fallback
        } else {
            items = []
        }
        totalPrice = try container.decodeIfPresent(Double.self, forKey: .totalPrice) ?? 0.0
        prescriptionUrl = try container.decodeIfPresent(String.self, forKey: .prescriptionUrl)
    }

    init(items: [OfferResultItemDTO], totalPrice: Double, prescriptionUrl: String? = nil) {
        self.items = items
        self.totalPrice = totalPrice
        self.prescriptionUrl = prescriptionUrl
    }
}

struct ProductNestedDTO: Decodable, Equatable {
    let id: Int?
    let name: String?
    let productName: String?
    let price: Double?
    let imageUrl: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case productName
        case price
        case imageUrl
    }
}

struct OfferResultItemDTO: Decodable, Equatable {
    let requestItemId: Int
    let productId: Int?
    let productName: String
    let imageUrl: String?
    let unitPrice: Double
    let isAlternative: Bool
    let isAvailable: Bool

    private enum CodingKeys: String, CodingKey {
        case requestItemId
        case productId
        case productName
        case imageUrl
        case unitPrice
        case isAlternative
        case alternative
        case isAvailable
        case available
        case product
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedProduct = try container.decodeIfPresent(ProductNestedDTO.self, forKey: .product)

        requestItemId = try container.decode(Int.self, forKey: .requestItemId)
        productId = try container.decodeIfPresent(Int.self, forKey: .productId) ?? nestedProduct?.id

        let nameAtTop = try container.decodeIfPresent(String.self, forKey: .productName)
        let nameCandidate = (nameAtTop?.isEmpty == false ? nameAtTop : nil) ?? nestedProduct?.name ?? nestedProduct?.productName ?? ""
        productName = nameCandidate

        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? nestedProduct?.imageUrl

        if let price = try container.decodeIfPresent(Double.self, forKey: .unitPrice), price > 0 {
            unitPrice = price
        } else {
            unitPrice = nestedProduct?.price ?? 0.0
        }

        if let alt = try container.decodeIfPresent(Bool.self, forKey: .isAlternative) {
            isAlternative = alt
        } else if let alt = try container.decodeIfPresent(Bool.self, forKey: .alternative) {
            isAlternative = alt
        } else {
            isAlternative = false
        }

        if let avail = try container.decodeIfPresent(Bool.self, forKey: .isAvailable) {
            isAvailable = avail
        } else if let avail = try container.decodeIfPresent(Bool.self, forKey: .available) {
            isAvailable = avail
        } else {
            isAvailable = (nestedProduct != nil)
        }
    }

    init(requestItemId: Int, productId: Int?, productName: String, imageUrl: String?, unitPrice: Double, isAlternative: Bool, isAvailable: Bool) {
        self.requestItemId = requestItemId
        self.productId = productId
        self.productName = productName
        self.imageUrl = imageUrl
        self.unitPrice = unitPrice
        self.isAlternative = isAlternative
        self.isAvailable = isAvailable
    }
}

struct RequestItemUpdatedEventDTO: Decodable, Equatable {
    let requestId: Int?
    let updatedItems: [UpdatedItemDTO]
}

struct UpdatedItemDTO: Decodable, Equatable {
    let requestItemId: Int
    let status: String?
    let product: ProductNestedDTO?
}

struct ConfirmOfferRequestDTO: Encodable, Equatable {
    let selectedRequestItemIds: [Int]
}

struct ConfirmOfferResponseDTO: Decodable, Equatable {
    let requestId: Int
    let orders: [ConfirmOfferOrderDTO]
}

struct ConfirmOfferOrderDTO: Decodable, Equatable {
    let orderId: Int
    let pharmacyId: Int
    let pharmacyName: String
    let itemIds: [Int]
}
