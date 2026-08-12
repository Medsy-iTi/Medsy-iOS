//  PharmacyRequestDetailsDTO.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

struct PharmacyRequestDetailsDTO: Decodable {
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
    let items: [PharmacyRequestDetailsItemDTO]
}

struct PharmacyRequestDetailsItemDTO: Decodable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
}
