//
//  CompleteRequestDTOs.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation

typealias SubmitCompleteRequestResponseDTO = APIResponseDTO<CompleteRequestResponseDTO>

// OLD:
// struct CompleteRequestDTO: Encodable, Equatable {
//     let deliveryLatitude: Double
//     let deliveryLongitude: Double
//     let deliveryAddress: String
// 
//     init(input: SubmitCompleteRequestInput) {
//         deliveryLatitude = input.deliveryLatitude
//         deliveryLongitude = input.deliveryLongitude
//         deliveryAddress = input.deliveryAddress
//     }
// }

struct CompleteRequestDTO: Encodable, Equatable {
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let notes: String?
    let paymentMethod: String

    let prescriptionData: Data?

    private enum CodingKeys: String, CodingKey {
        case deliveryLatitude
        case deliveryLongitude
        case deliveryAddress
        case notes
        case paymentMethod
    }

    init(input: SubmitCompleteRequestInput) {
        deliveryLatitude = input.deliveryLatitude
        deliveryLongitude = input.deliveryLongitude
        deliveryAddress = input.deliveryAddress
        notes = input.notes?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        paymentMethod = input.paymentMethod
        prescriptionData = input.prescriptionData
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

struct CompleteRequestResponseDTO: Decodable, Equatable {
    let id: Int
    let customerId: Int
    let customerName: String
    let customerPhone: String
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let status: String
    let createdAt: String
    let items: [CompleteRequestResponseItemDTO]
    let prescriptionUrl: String?
    let notes: String?
}

struct CompleteRequestResponseItemDTO: Decodable, Equatable {
    let id: Int
    let productId: Int
    let imageUrl: String?
    let productName: String
    let strength: String
    let packSize: String
    let form: String
    let quantity: Int
    let unitPrice: Double

    private enum CodingKeys: String, CodingKey {
        case id
        case productId
        case imageUrl
        case productName
        case strength
        case packSize
        case form
        case quantity
        case unitPrice
        case product
    }

    private enum ProductCodingKeys: String, CodingKey {
        case name
        case productName
        case imageUrl
        case strength
        case packSize
        case form
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        productId = try container.decode(Int.self, forKey: .productId)
        quantity = try container.decode(Int.self, forKey: .quantity)
        unitPrice = try container.decode(Double.self, forKey: .unitPrice)

        let productContainer = try? container.nestedContainer(keyedBy: ProductCodingKeys.self, forKey: .product)
        let topName = try container.decodeIfPresent(String.self, forKey: .productName)
        let nestedName = (try? productContainer?.decodeIfPresent(String.self, forKey: .productName)) ?? (try? productContainer?.decodeIfPresent(String.self, forKey: .name))
        productName = topName ?? nestedName ?? ""

        let topImage = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        let nestedImage = try? productContainer?.decodeIfPresent(String.self, forKey: .imageUrl)
        imageUrl = topImage ?? nestedImage

        let topStrength = try container.decodeIfPresent(String.self, forKey: .strength)
        let nestedStrength = try? productContainer?.decodeIfPresent(String.self, forKey: .strength)
        strength = topStrength ?? nestedStrength ?? ""

        let topPackSize = try container.decodeIfPresent(String.self, forKey: .packSize)
        let nestedPackSize = try? productContainer?.decodeIfPresent(String.self, forKey: .packSize)
        packSize = topPackSize ?? nestedPackSize ?? ""

        let topForm = try container.decodeIfPresent(String.self, forKey: .form)
        let nestedForm = try? productContainer?.decodeIfPresent(String.self, forKey: .form)
        form = topForm ?? nestedForm ?? ""
    }
}
