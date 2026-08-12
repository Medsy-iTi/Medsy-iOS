//
//  CartPrescriptionAttachment.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

struct CartPrescriptionAttachment: Identifiable, Equatable {
    let id: UUID
    let imageData: Data
    let source: CartPrescriptionSource
    let createdAt: Date

    init(
        id: UUID = UUID(),
        imageData: Data,
        source: CartPrescriptionSource,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.imageData = imageData
        self.source = source
        self.createdAt = createdAt
    }
}

struct CartRequestDraft: Equatable {
    let items: [CartDisplayItem]
    let prescriptions: [CartPrescriptionAttachment]
    let pharmacistNote: String

    init(
        items: [CartDisplayItem],
        prescriptions: [CartPrescriptionAttachment],
        pharmacistNote: String = ""
    ) {
        self.items = items
        self.prescriptions = prescriptions
        self.pharmacistNote = pharmacistNote
    }

}
