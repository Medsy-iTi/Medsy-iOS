//
//  PrescriptionMedicineDisplay.swift
//  Medsy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import Foundation

struct PrescriptionMedicineDisplay: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let details: String
    let price: String
    let needsReview: Bool

    static let samples = [
        PrescriptionMedicineDisplay(name: "Panadol Extra", details: "20 tablets", price: "$4.50", needsReview: false),
        PrescriptionMedicineDisplay(name: "Augmentin", details: "1 g · 14 tablets", price: "$8.00", needsReview: false),
        PrescriptionMedicineDisplay(name: "Telfast", details: "120 mg · 10 tablets", price: "$5.50", needsReview: false),
        PrescriptionMedicineDisplay(name: "Medicine name unclear", details: "Needs your review", price: "$2.50", needsReview: true)
    ]
}
