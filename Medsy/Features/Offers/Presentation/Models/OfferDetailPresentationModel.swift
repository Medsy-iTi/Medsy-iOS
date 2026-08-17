//
//  OfferDetailPresentationModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct OfferMedicineItem: Identifiable, Hashable {
    let id: String
    let requestItemId: Int
    let productId: Int?
    let name: String
    let dosage: String
    let price: Double
    let isAvailable: Bool
    let isAlternative: Bool
    let imageName: String
    let imageUrl: String?
    var isSelected: Bool
    var quantity: Int
    var supplierName: String?

    init(
        id: String,
        requestItemId: Int = 0,
        productId: Int? = nil,
        name: String,
        dosage: String,
        price: Double,
        isAvailable: Bool = true,
        isAlternative: Bool = false,
        imageName: String = "pill.fill",
        imageUrl: String? = nil,
        isSelected: Bool = true,
        quantity: Int = 1,
        supplierName: String? = nil
    ) {
        self.id = id
        self.requestItemId = requestItemId
        self.productId = productId
        self.name = name
        self.dosage = dosage
        self.price = price
        self.isAvailable = isAvailable
        self.isAlternative = isAlternative
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.isSelected = isAvailable ? isSelected : false
        self.quantity = quantity
        self.supplierName = supplierName
    }
}

struct OfferDetailPresentationModel: Identifiable, Hashable {
    let id: String
    let pharmacyName: String
    let managerName: String
    let medicines: [OfferMedicineItem]
    let pharmacistComment: String
    let totalPrice: Double
    let prescriptionUrl: String?
    let paymentMethod: String?
    let deliveryAddress: String?

    init(
        id: String,
        pharmacyName: String,
        managerName: String,
        medicines: [OfferMedicineItem],
        pharmacistComment: String,
        totalPrice: Double,
        prescriptionUrl: String? = nil,
        paymentMethod: String? = nil,
        deliveryAddress: String? = nil
    ) {
        self.id = id
        self.pharmacyName = pharmacyName
        self.managerName = managerName
        self.medicines = medicines
        self.pharmacistComment = pharmacistComment
        self.totalPrice = totalPrice
        self.prescriptionUrl = prescriptionUrl
        self.paymentMethod = paymentMethod
        self.deliveryAddress = deliveryAddress
    }
}
