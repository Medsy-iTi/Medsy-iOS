//
//  OrderDTOs.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

typealias OrdersPageResponseDTO = APIResponseDTO<PageDTO<OrderDTO>>
typealias OrderDetailResponseDTO = APIResponseDTO<OrderDTO>

struct OrderDTO: Decodable {
    let id: Int
    let userId: Int
    let pharmacyId: Int
    let pharmacistId: Int?
    let offerId: Int?
    let totalPrice: Double
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let status: String
    let date: String
    let items: [OrderItemDTO]

    let pharmacyName: String?
    let fulfillmentType: String?
    let deliveryFee: Double?
    let itemsSubtotal: Double?

    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case customerId
        case pharmacyId
        case pharmacistId
        case offerId
        case totalPrice
        case total
        case deliveryLatitude
        case deliveryLongitude
        case status
        case date
        case createdAt
        case items
        case pharmacyName
        case fulfillmentType
        case deliveryFee
        case itemsSubtotal
        case subTotal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
            ?? container.decode(Int.self, forKey: .customerId)
        pharmacyId = try container.decode(Int.self, forKey: .pharmacyId)
        pharmacistId = try container.decodeIfPresent(Int.self, forKey: .pharmacistId)
        offerId = try container.decodeIfPresent(Int.self, forKey: .offerId)
        totalPrice = try container.decodeIfPresent(Double.self, forKey: .totalPrice)
            ?? container.decode(Double.self, forKey: .total)
        deliveryLatitude = try container.decodeIfPresent(Double.self, forKey: .deliveryLatitude)
        deliveryLongitude = try container.decodeIfPresent(Double.self, forKey: .deliveryLongitude)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "PENDING"
        date = try container.decodeIfPresent(String.self, forKey: .date)
            ?? container.decode(String.self, forKey: .createdAt)
        items = try container.decode([OrderItemDTO].self, forKey: .items)
        pharmacyName = try container.decodeIfPresent(String.self, forKey: .pharmacyName)
        fulfillmentType = try container.decodeIfPresent(String.self, forKey: .fulfillmentType)
        deliveryFee = try container.decodeIfPresent(Double.self, forKey: .deliveryFee)
        itemsSubtotal = try container.decodeIfPresent(Double.self, forKey: .itemsSubtotal)
            ?? container.decodeIfPresent(Double.self, forKey: .subTotal)
    }
}

struct OrderItemDTO: Decodable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
    let productName: String?
    let originalProductName: String?
    let imageUrl: String?
    let totalPrice: Double?
}
