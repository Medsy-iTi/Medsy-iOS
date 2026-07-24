//
//  CartPrescription.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

enum CartPrescriptionSource: String, Equatable {
    case camera
    case photoLibrary
}

struct CartPrescription: Identifiable, Equatable {
    let id: UUID
    let data: Data
    let source: CartPrescriptionSource
    let createdAt: Date

    init(
        id: UUID = UUID(),
        data: Data,
        source: CartPrescriptionSource,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.data = data
        self.source = source
        self.createdAt = createdAt
    }
}
