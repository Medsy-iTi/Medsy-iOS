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
}

struct OrderItemDTO: Decodable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
}
