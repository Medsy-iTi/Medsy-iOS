//
//  CompletedOrderDTOs.swift
//  Medsy
//

import Foundation

typealias CompletedOrderDetailResponseDTO = APIResponseDTO<CompletedOrderDetailsDTO>

struct CompletedOrderDetailsDTO: Decodable {
    let id: Int
    let customerId: Int
    let customerName: String
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacyAddress: String
    let pharmacyPhone: String
    let pharmacistId: Int
    let pharmacistName: String
    let offerId: Int?
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let createdAt: String
    let items: [CompletedOrderItemDTO]
}

struct CompletedOrderDetailsItemDTO: Decodable {
    let id: Int
    let productId: Int
    let productName: String
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}
