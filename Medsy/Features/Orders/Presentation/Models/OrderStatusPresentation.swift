//
//  OrderStatusPresentation.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//


import SwiftUI

enum OrderStatusPresentation {
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

    var labelKey: String {
        switch self {
        case .pending:             "orders.status.pending"
        case .pendingPayment:      "orders.status.pending_payment"
        case .confirmed:           "orders.status.confirmed"
        case .preparing:           "orders.status.preparing"
        case .readyForPickup:      "orders.status.ready_for_pickup"
        case .readyForDelivery:    "orders.status.ready_for_delivery"
        case .outForDelivery:      "orders.status.out_for_delivery"
        case .delivered:           "orders.status.delivered"
        case .cancelled:           "orders.status.cancelled"
        case .unknown(let raw):    raw
        }
    }

    var color: Color {
        switch self {
        case .pending, .pendingPayment, .confirmed, .preparing, .readyForPickup, .readyForDelivery, .outForDelivery:
            return AppColor.green
        case .delivered:
            return AppColor.green
        case .cancelled:
            return AppColor.errorRed
        case .unknown:
            return AppColor.textSec
        }
    }

    var isActive: Bool {
        switch self {
        case .pending, .pendingPayment, .confirmed, .preparing, .readyForPickup, .readyForDelivery, .outForDelivery: return true
        default: return false
        }
    }

    var isCompleted: Bool {
        if case .delivered = self { return true }
        return false
    }

    var isCancelled: Bool {
        switch self {
        case .cancelled: return true
        default: return false
        }
    }
}
