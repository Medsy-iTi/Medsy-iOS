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

    init(
        id: UUID = UUID(),
        imageData: Data,
        source: CartPrescriptionSource
    ) {
        self.id = id
        self.imageData = imageData
        self.source = source
    }
}

struct CartRequestDraft: Equatable {
    let items: [CartDisplayItem]
    let prescription: CartPrescriptionAttachment?
}
