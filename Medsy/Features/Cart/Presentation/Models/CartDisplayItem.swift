//
//  CartDisplayItem.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import Foundation

struct CartDisplayItem: Identifiable, Equatable {
    let id: String
    let name: String
    let dosageInfo: String
    let unitPrice: Double
    let quantity: Int
    let imageUrl: String?

    var lineTotal: Double {
        unitPrice * Double(quantity)
    }
}

enum CartViewState: Equatable {
    case loading
    case empty
    case loaded([CartDisplayItem])
    case error(String)
}

enum CartSampleData {
    static let items: [CartDisplayItem] = [
        CartDisplayItem(
            id: "1",
            name: "Panadol Extra",
            dosageInfo: "20 tablets",
            unitPrice: 45,
            quantity: 2,
            imageUrl: nil
        ),
        CartDisplayItem(
            id: "2",
            name: "Augmentin",
            dosageInfo: "1 g • 14 tablets",
            unitPrice: 180,
            quantity: 1,
            imageUrl: nil
        ),
        CartDisplayItem(
            id: "3",
            name: "Telfast",
            dosageInfo: "120 mg • 10 tablets",
            unitPrice: 95,
            quantity: 1,
            imageUrl: nil
        )
    ]
}
