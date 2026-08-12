//
//  OrderDTOs.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

typealias OrdersPageResponseDTO = APIResponseDTO<PageDTO<MasterOrderDTO>>
typealias OrderDetailResponseDTO = APIResponseDTO<MasterOrderDTO>

struct MasterOrderDTO: Decodable {
    let id: Int
    let requestId: Int
    let orderResponses: [MasterOrderPharmacyDTO]
    let paymentMethod: String?
    let paymentStatus: String?
    let fulfillmentMethod: String?
    let deliveryFee: Double?
    let totalPrice: Double
    let orderStatus: String
    let paymentExpiresAt: String?
    let paidAt: String?
}

struct MasterOrderPharmacyDTO: Decodable {
    let offerId: Int
    let pharmacyId: Int
    let pharmacyName: String
    let latitude: Double?
    let longitude: Double?
    let items: [MasterOrderItemDTO]
}

struct MasterOrderItemDTO: Decodable {
    let id: Int
    let productId: Int?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double?
    let product: MasterOrderProductDTO?
}

struct MasterOrderProductDTO: Decodable {
    let id: Int
    let name: String?
    let productName: String?
    let strength: String?
    let packSize: String?
    let form: String?
    let price: Double?
    let scientificName: String?
    let company: String?
    let route: String?
    let description: String?
    let imageUrl: String?
}
