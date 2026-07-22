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
        self.confidence = confidence
        self.isConfirmed = isConfirmed
    }

    static let samples = [
        PrescriptionMedicineDisplay(
            name: "ABILIFY 15 MG 10 TABS.",
            details: "ARIPIPRAZOLE",
            price: "330 EGP",
            imageName: "pills.fill",
            confidence: .identified,
            isConfirmed: true
        ),
        PrescriptionMedicineDisplay(
            name: "ABILIFY 5 MG 10 TABS.",
            details: "ARIPIPRAZOLE",
            price: "134 EGP",
            imageName: "cross.case.fill",
            confidence: .identified,
            isConfirmed: true
        ),
        PrescriptionMedicineDisplay(
            name: "ABIMOL 500 MG 20 TAB.",
            details: "PARACETAMOL(ACETAMINOPHEN)",
            price: "24 EGP",
            imageName: "capsule.portrait.fill",
            confidence: .identified,
            isConfirmed: true
        ),
        PrescriptionMedicineDisplay(
            name: "ABIMOL EXTRA 20 TAB.",
            details: "CAFFEINE+PARACETAMOL(ACETAMINOPHEN)",
            price: "28 EGP",
            imageName: "pills.circle.fill",
            confidence: .needsReview
        )
    ]
}
