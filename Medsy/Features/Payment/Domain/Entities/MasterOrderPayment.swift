//
//  MasterOrderPayment.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

enum MasterOrderPaymentMethod: String, Equatable, Sendable {
    case cash = "CASH"
    case card = "CARD"
    case unknown
}

enum MasterOrderPaymentStatus: String, Equatable, Sendable {
    case pending = "PENDING"
    case paid = "PAID"
    case failed = "FAILED"
    case cancelled = "CANCELLED"
    case expired = "EXPIRED"
    case unknown
}

enum MasterOrderStatus: String, Equatable, Sendable {
    case pendingPayment = "PENDING_PAYMENT"
    case preparing = "PREPARING"
    case ready = "READY"
    case outForDelivery = "OUT_FOR_DELIVERY"
    case delivered = "DELIVERED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    case unknown
}

struct MasterOrderPayment: Equatable, Sendable {
    let id: Int
    let paymentMethod: MasterOrderPaymentMethod
    let paymentStatus: MasterOrderPaymentStatus
    let orderStatus: MasterOrderStatus
    let paymentExpiresAt: Date?
    let paidAt: Date?
}
