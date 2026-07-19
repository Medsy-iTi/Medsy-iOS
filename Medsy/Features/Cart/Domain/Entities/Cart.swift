//
//  Cart.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

struct Cart: Equatable {
    let id: Int64?
    let items: [CartItem]
    let prescriptions: [CartPrescription]
    let totalPrice: Double

    init(
        id: Int64? = nil,
        items: [CartItem] = [],
        prescriptions: [CartPrescription] = [],
        totalPrice: Double? = nil
    ) {
        self.id = id
        self.items = items
        self.prescriptions = prescriptions
        self.totalPrice = totalPrice ?? items.reduce(0) { $0 + $1.subtotal }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var hasContent: Bool {
        !items.isEmpty || !prescriptions.isEmpty
    }

    func withPrescriptions(_ prescriptions: [CartPrescription]) -> Cart {
        Cart(
            id: id,
            items: items,
            prescriptions: prescriptions,
            totalPrice: totalPrice
        )
    }
}
