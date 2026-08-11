//
//  OrderEntity.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

enum OrderStatus {
    case pending
    case confirmed
    case preparing
    case readyForPickup
    case outForDelivery
    case delivered
    case cancelled
    case unknown(String)

    var rawValue: String {
        switch self {
        case .pending:          return "PENDING"
        case .confirmed:        return "CONFIRMED"
        case .preparing:        return "PREPARING"
        case .readyForPickup:   return "READY_FOR_PICKUP"
        case .outForDelivery:   return "OUT_FOR_DELIVERY"
        case .delivered:        return "DELIVERED"
        case .cancelled:        return "CANCELLED"
        case .unknown(let raw): return raw
        }
    }

    init(rawValue: String) {
        switch rawValue.uppercased() {
        case "PENDING", "PENDING_PAYMENT": self = .pending
        case "CONFIRMED":  self = .confirmed
        case "PREPARING":        self = .preparing
        case "READY_FOR_PICKUP": self = .readyForPickup
        case "OUT_FOR_DELIVERY": self = .outForDelivery
        case "DELIVERED":  self = .delivered
        case "CANCELLED":  self = .cancelled
        default:           self = .unknown(rawValue)
        }
    }
}

enum OrderFulfillmentType: String, Equatable {
    case delivery = "DELIVERY"
    case pickup = "PICKUP"

    init(rawValue: String?, hasDeliveryCoordinates: Bool) {
        switch rawValue?.uppercased() {
        case "PICKUP", "PICK_UP": self = .pickup
        case "DELIVERY": self = .delivery
        default: self = hasDeliveryCoordinates ? .delivery : .pickup
        }
    }
}

struct OrderEntity: Identifiable {
    let id: Int
    let orderNumber: Int
    let pharmacyName: String
    let status: OrderStatus
    let fulfillmentType: OrderFulfillmentType
    let date: Date
    let totalPrice: Double
    let itemCount: Int
    let itemImageURLs: [String]
    let paymentMethod: MasterOrderPaymentMethod
    let paymentStatus: MasterOrderPaymentStatus
    let paymentExpiresAt: Date?

    init(
        id: Int,
        orderNumber: Int,
        pharmacyName: String,
        status: OrderStatus,
        fulfillmentType: OrderFulfillmentType,
        date: Date,
        totalPrice: Double,
        itemCount: Int,
        itemImageURLs: [String],
        paymentMethod: MasterOrderPaymentMethod = .unknown,
        paymentStatus: MasterOrderPaymentStatus = .unknown,
        paymentExpiresAt: Date? = nil
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.pharmacyName = pharmacyName
        self.status = status
        self.fulfillmentType = fulfillmentType
        self.date = date
        self.totalPrice = totalPrice
        self.itemCount = itemCount
        self.itemImageURLs = itemImageURLs
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
        self.paymentExpiresAt = paymentExpiresAt
    }
}
