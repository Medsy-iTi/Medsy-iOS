//
//  ConfirmOfferResult.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct ConfirmOfferOrder: Equatable, Hashable {
    let orderId: Int
    let pharmacyId: Int
    let pharmacyName: String
    let itemIds: [Int]
}

struct ConfirmOfferResult: Equatable, Hashable {
    let requestId: Int
    let orders: [ConfirmOfferOrder]
}
