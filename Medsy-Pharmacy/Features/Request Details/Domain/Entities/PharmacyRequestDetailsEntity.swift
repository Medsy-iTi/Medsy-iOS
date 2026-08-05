//  PharmacyRequestDetailsEntity.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

struct PharmacyRequestDetailsEntity: Identifiable, Equatable, Sendable {
    let id: Int
    let userId: Int
    let pharmacyId: Int
    let pharmacistId: Int?
    let offerId: Int?
    let totalPrice: Double
    let deliveryCoordinate: (latitude: Double, longitude: Double)
    let status: PharmacyOrderAPIStatus
    let date: Date
    let items: [PharmacyRequestDetailsItemEntity]

    static func == (lhs: PharmacyRequestDetailsEntity, rhs: PharmacyRequestDetailsEntity) -> Bool {
        lhs.id == rhs.id
            && lhs.status == rhs.status
            && lhs.totalPrice == rhs.totalPrice
            && lhs.items == rhs.items
    }
}

struct PharmacyRequestDetailsItemEntity: Identifiable, Equatable, Sendable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
}
