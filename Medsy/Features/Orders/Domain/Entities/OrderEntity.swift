//
//  OrderEntity.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

enum OrderStatus {
    case pending
    case pendingPayment
    case confirmed
    case preparing
    case readyForPickup
    case readyForDelivery
    case outForDelivery
    case delivered
    case cancelled
    case unknown(String)

    var rawValue: String {
        switch self {
        case .pending:          return "PENDING"
        case .pendingPayment:   return "PENDING_PAYMENT"
        case .confirmed:        return "CONFIRMED"
        case .preparing:        return "PREPARING"
        case .readyForPickup:   return "READY_FOR_PICKUP"
        case .readyForDelivery: return "READY_FOR_DELIVERY"
        case .outForDelivery:   return "OUT_FOR_DELIVERY"
        case .delivered:        return "DELIVERED"
        case .cancelled:        return "CANCELLED"
        case .unknown(let raw): return raw
        }
    }

    init(rawValue: String) {
        switch rawValue.uppercased() {
        case "PENDING":    self = .pending
        case "PENDING_PAYMENT": self = .pendingPayment
        case "CONFIRMED":  self = .confirmed
        case "PREPARING":        self = .preparing
        case "READY_FOR_PICKUP": self = .readyForPickup
        case "READY_FOR_DELIVERY": self = .readyForDelivery
        case "OUT_FOR_DELIVERY": self = .outForDelivery
        case "DELIVERED":  self = .delivered
        case "CANCELLED":  self = .cancelled
        default:           self = .unknown(rawValue)
        }
    }
}

enum OrderPaymentMethod: String, Equatable {
    case cash = "CASH"
    case card = "CARD"
}

enum OrderPaymentStatus: String, Equatable {
    case unpaid = "UNPAID"
    case pending = "PENDING"
    case paid = "PAID"
    case failed = "FAILED"
    case canceled = "CANCELED"
    case expired = "EXPIRED"
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
    let requestID: Int?
    let pharmacyNames: [String]
    let paymentMethod: OrderPaymentMethod?
    let paymentStatus: OrderPaymentStatus?
    let paymentExpiresAt: Date?
    let paidAt: Date?

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
        requestID: Int? = nil,
        pharmacyNames: [String] = [],
        paymentMethod: OrderPaymentMethod? = nil,
        paymentStatus: OrderPaymentStatus? = nil,
        paymentExpiresAt: Date? = nil,
        paidAt: Date? = nil
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
        self.requestID = requestID
        self.pharmacyNames = pharmacyNames
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
        self.paymentExpiresAt = paymentExpiresAt
        self.paidAt = paidAt
    }
}
