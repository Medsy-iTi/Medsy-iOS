//
//  CompletedOrderItem.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//

import Foundation

struct CompletedOrderItem: Identifiable, Equatable {
    let id: Int
    let productId: Int
    let productName: String
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}
