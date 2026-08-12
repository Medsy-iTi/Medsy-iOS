//
//  SubmittedMedicineRequest.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation

// OLD:
// struct SubmitCompleteRequestInput: Equatable {
//     let deliveryLatitude: Double
//     let deliveryLongitude: Double
//     let deliveryAddress: String
// }

struct SubmitCompleteRequestInput: Equatable {
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let notes: String?
    let paymentMethod: String
    let prescriptionData: Data?

    init(
        deliveryLatitude: Double,
        deliveryLongitude: Double,
        deliveryAddress: String,
        notes: String? = nil,
        paymentMethod: String = "CASH",
        prescriptionData: Data? = nil
    ) {
        self.deliveryLatitude = deliveryLatitude
        self.deliveryLongitude = deliveryLongitude
        self.deliveryAddress = deliveryAddress
        self.notes = notes
        self.paymentMethod = paymentMethod
        self.prescriptionData = prescriptionData
    }
}

struct SubmittedMedicineRequest: Equatable {
    let id: Int
    let customerID: Int
    let customerName: String
    let customerPhone: String
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let status: String
    let createdAt: Date
    let items: [SubmittedMedicineRequestItem]
    let prescriptionURL: String?
    let notes: String?

    init(
        id: Int,
        customerID: Int,
        customerName: String = "",
        customerPhone: String = "",
        deliveryLatitude: Double,
        deliveryLongitude: Double,
        deliveryAddress: String,
        status: String,
        createdAt: Date,
        items: [SubmittedMedicineRequestItem],
        prescriptionURL: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.customerID = customerID
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.deliveryLatitude = deliveryLatitude
        self.deliveryLongitude = deliveryLongitude
        self.deliveryAddress = deliveryAddress
        self.status = status
        self.createdAt = createdAt
        self.items = items
        self.prescriptionURL = prescriptionURL
        self.notes = notes
    }
}

struct SubmittedMedicineRequestItem: Equatable {
    let id: Int
    let productID: Int
    let quantity: Int
    let imageURL: String?
    let productName: String
    let strength: String
    let packSize: String
    let form: String
    let unitPrice: Double

    init(
        id: Int,
        productID: Int,
        quantity: Int,
        imageURL: String? = nil,
        productName: String = "",
        strength: String = "",
        packSize: String = "",
        form: String = "",
        unitPrice: Double = 0
    ) {
        self.id = id
        self.productID = productID
        self.quantity = quantity
        self.imageURL = imageURL
        self.productName = productName
        self.strength = strength
        self.packSize = packSize
        self.form = form
        self.unitPrice = unitPrice
    }
}
