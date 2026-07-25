//
//  PharmacyMedicineRequestDTO.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct PharmacyMedicineRequestDTO: Decodable, Equatable {
    let id: Int
    let customerId: Int?
    let customerName: String?
    let customerPhone: String?
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let deliveryAddress: String?
    let status: String
    let createdAt: String?
    let items: [PharmacyMedicineRequestItemDTO]?
    let prescriptionUrl: String?
    let notes: String?
}

struct PharmacyMedicineRequestItemDTO: Decodable, Equatable {
    let id: Int
    let productId: Int
    let imageUrl: String?
    let productName: String?
    let quantity: Int
    let unitPrice: Double?
    let form: String?
    let strength: String?
    let packSize: String?
}
