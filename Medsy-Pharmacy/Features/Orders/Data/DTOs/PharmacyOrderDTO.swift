//
//  APIEnvelope.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//


import Foundation


struct APIEnvelope<T: Decodable>: Decodable {
	let success: Bool
	let message: String
	let data: T?
}

struct PageResponseDTO<Item: Decodable>: Decodable {
	let content: [Item]
	let pageNumber: Int
	let pageSize: Int
	let totalElements: Int
	let totalPages: Int
	let last: Bool
}

struct PharmacyOrderDTO: Decodable {
	let id: Int
	let userId: Int
	let pharmacyId: Int
	let pharmacistId: Int?
	let offerId: Int?
	let totalPrice: Double
	let deliveryLatitude: Double
	let deliveryLongitude: Double
	let status: String
	let date: String
	let paymentMethod: String?
	let items: [PharmacyOrderItemDTO]
}

struct PharmacyOrderItemDTO: Decodable {
	let id: Int
	let productId: Int
	let quantity: Int
	let unitPrice: Double
}
