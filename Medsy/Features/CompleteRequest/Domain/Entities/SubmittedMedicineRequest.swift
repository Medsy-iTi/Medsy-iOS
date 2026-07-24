//
//  SubmittedMedicineRequest.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation

struct SubmitCompleteRequestInput: Equatable {
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
}

struct SubmittedMedicineRequest: Equatable {
    let id: Int
    let customerID: Int
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let status: String
    let createdAt: Date
    let items: [SubmittedMedicineRequestItem]
}

struct SubmittedMedicineRequestItem: Equatable {
    let id: Int
    let productID: Int
    let quantity: Int
}
