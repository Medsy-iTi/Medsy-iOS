//
//  PrescriptionMedicineDisplay.swift
//  Medsy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import Foundation

enum PrescriptionMedicineConfidence: Equatable {
    case identified
    case needsReview
}

struct PrescriptionMedicineDisplay: Identifiable, Equatable {
    let id: UUID
    var name: String
    var details: String
    var price: String
    var unit: String
    var quantity: Int
    var imageName: String
    var productID: Int64?
    var unitPrice: Double?
    var imageURL: String?
    var confidence: PrescriptionMedicineConfidence
    var isConfirmed: Bool

    var needsReview: Bool {
        confidence == .needsReview
    }

    init(
        id: UUID = UUID(),
        name: String,
        details: String,
        price: String,
        unit: String = "prescription.review.perPack",
        quantity: Int = 1,
        imageName: String = "pills.fill",
        productID: Int64? = nil,
        unitPrice: Double? = nil,
        imageURL: String? = nil,
        confidence: PrescriptionMedicineConfidence,
        isConfirmed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.price = price
        self.unit = unit
        self.quantity = quantity
        self.imageName = imageName
        self.productID = productID
        self.unitPrice = unitPrice
        self.imageURL = imageURL
        self.confidence = confidence
        self.isConfirmed = isConfirmed
    }

    var cartItem: CartDisplayItem? {
        guard let productID, let unitPrice else { return nil }
        return CartDisplayItem(
            id: String(productID),
            productID: productID,
            name: name,
            dosageInfo: details,
            unitPrice: unitPrice,
            quantity: quantity,
            imageUrl: imageURL
        )
    }

    static let samples = [
        PrescriptionMedicineDisplay(
            name: "ABILIFY 15 MG 10 TABS.",
            details: "ARIPIPRAZOLE",
            price: "330 EGP",
            imageName: "pills.fill",
            productID: 1,
            unitPrice: 330.5,
            imageURL: "https://cdn.shopify.com/s/files/1/0774/7151/4932/files/abilify-15-mg-10-tablets-956297.jpg?v=1729196907",
            confidence: .identified,
            isConfirmed: true
        ),
        PrescriptionMedicineDisplay(
            name: "ABILIFY 5 MG 10 TABS.",
            details: "ARIPIPRAZOLE",
            price: "134 EGP",
            imageName: "cross.case.fill",
            productID: 2,
            unitPrice: 134.5,
            imageURL: "https://cdn.shopify.com/s/files/1/0774/7151/4932/products/abilify-5-mg-10-tablets-9172616.jpg?v=1762508400",
            confidence: .identified,
            isConfirmed: true
        ),
        PrescriptionMedicineDisplay(
            name: "ABIMOL 500 MG 20 TAB.",
            details: "PARACETAMOL(ACETAMINOPHEN)",
            price: "24 EGP",
            imageName: "capsule.portrait.fill",
            productID: 3,
            unitPrice: 24,
            imageURL: "https://cdn.shopify.com/s/files/1/0774/7151/4932/products/abimol-500-mg-20-tablets-7308198.jpg?v=1764283687",
            confidence: .identified,
            isConfirmed: true
        ),
        PrescriptionMedicineDisplay(
            name: "ABIMOL EXTRA 20 TAB.",
            details: "CAFFEINE+PARACETAMOL(ACETAMINOPHEN)",
            price: "28 EGP",
            imageName: "pills.circle.fill",
            productID: 4,
            unitPrice: 28,
            imageURL: "https://demov2.egypt.dawatech.com/web/image/product.template/16570/image_1920",
            confidence: .needsReview
        )
    ]
}
