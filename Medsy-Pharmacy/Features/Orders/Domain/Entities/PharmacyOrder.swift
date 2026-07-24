//
//  PharmacyOrder.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//


import Foundation

struct PharmacyOrder: Identifiable, Equatable, Sendable {
    let id: Int
    let userId: Int
    let pharmacyId: Int
    let totalPrice: Double
    let deliveryCoordinate: (latitude: Double, longitude: Double)
    let status: PharmacyOrderAPIStatus
    let date: Date
    let items: [PharmacyOrderLineItem]

    static func == (lhs: PharmacyOrder, rhs: PharmacyOrder) -> Bool {
        lhs.id == rhs.id
            && lhs.status == rhs.status
            && lhs.totalPrice == rhs.totalPrice
            && lhs.items == rhs.items
    }
}

struct PharmacyOrderLineItem: Identifiable, Equatable, Sendable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
}


enum PharmacyOrderAPIStatus: Equatable, Sendable {
    case pending
    case accepted
    case preparing
    case outForDelivery
    case delivered
    case cancelled
    case unknown(String)

    init(rawValue: String) {
        switch rawValue.uppercased() {
        case "PENDING": self = .pending
        case "ACCEPTED": self = .accepted
        case "PREPARING": self = .preparing
        case "OUT_FOR_DELIVERY": self = .outForDelivery
        case "DELIVERED": self = .delivered
        case "CANCELLED", "CANCELED": self = .cancelled
        default: self = .unknown(rawValue)
        }
    }
}

struct PharmacyOrdersPage: Sendable {
    let orders: [PharmacyOrder]
    let pageNumber: Int
    let totalPages: Int
    let isLastPage: Bool
}
