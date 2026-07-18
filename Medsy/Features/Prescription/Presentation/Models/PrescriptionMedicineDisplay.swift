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
        confidence: PrescriptionMedicineConfidence,
        isConfirmed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.price = price
        self.confidence = confidence
        self.isConfirmed = isConfirmed
    }

    static let samples = [
        PrescriptionMedicineDisplay(name: "Panadol Extra", details: "20 tablets", price: "45.00 EGP", confidence: .identified),
        PrescriptionMedicineDisplay(name: "Augmentin", details: "1 g · 14 tablets", price: "180.00 EGP", confidence: .identified),
        PrescriptionMedicineDisplay(name: "Telfast", details: "120 mg · 10 tablets", price: "95.00 EGP", confidence: .identified),
        PrescriptionMedicineDisplay(name: "Medicine name unclear", details: "Needs your review", price: "--", confidence: .needsReview)
    ]
}
