//
//  CompletedOrderDTOs.swift
//  Medsy
//

import Foundation

typealias CompletedOrderDetailResponseDTO = APIResponseDTO<CompletedOrderDetailsDTO>

struct CompletedOrderDetailsDTO: Decodable {
    let id: Int
    let customerId: Int
    let customerName: String?
    let customerNotes: String?
    let pharmacistNotes: String?
    let prescriptionUrl: String?
    let offerId: Int?
    let subTotal: Double
    let deliveryFee: Double?
    let total: Double
    let createdAt: String
    let status: String?
    let fulfillmentMethod: String?
    let items: [CompletedOrderDetailsItemDTO]
    
    let deliveryAddress: String?
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let phoneNumber: String?
    
    let pharmacistName: String?
    let pharmacyPhone: String?
    let pharmacyAddress: String?
}

struct CompletedOrderDetailsProductDTO: Decodable {
    let id: Int?
    let name: String?
    let productName: String?
    let imageUrl: String?
    let form: String?
    let strength: String?
    let packSize: String?
    let scientificName: String?
    let description: String?
    let company: String?
    let price: Double?
}

struct CompletedOrderDetailsItemDTO: Decodable {
    let id: Int
    let productId: Int
    let product: CompletedOrderDetailsProductDTO?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}
