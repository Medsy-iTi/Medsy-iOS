//
//  PharmacyMedicineRequestEntity.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct PharmacyMedicineRequestEntity: Identifiable, Equatable, Sendable {
    let id: Int
    let customerId: Int?
    let customerName: String?
    let customerPhone: String?
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let status: PharmacyOrderAPIStatus
    let createdAt: Date?
    let items: [PharmacyMedicineRequestItemEntity]
    let prescriptionUrl: String?
    let notes: String?
}

struct PharmacyMedicineRequestItemEntity: Identifiable, Equatable, Sendable {
    let id: Int
    let productId: Int
    let imageUrl: String?
    let productName: String
    let quantity: Int
    let unitPrice: Double
    let form: String?
    let strength: String?
    let packSize: String?
}
