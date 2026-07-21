//
//  OrderStatusPresentation.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//


import SwiftUI

enum OrderStatusPresentation {
    case pending
    case confirmed
    case processing
    case shipped
    case delivered
    case cancelled
    case rejected
    case unknown(String)

    init(rawValue: String) {
        switch rawValue.uppercased() {
        case "PENDING":    self = .pending
        case "CONFIRMED":  self = .confirmed
        case "PROCESSING": self = .processing
        case "SHIPPED":    self = .shipped
        case "DELIVERED":  self = .delivered
        case "CANCELLED":  self = .cancelled
        case "REJECTED":   self = .rejected
        default:           self = .unknown(rawValue)
        }
    }

    var labelKey: String {
        switch self {
        case .pending:             "orders.status.pending"
        case .confirmed:           "orders.status.confirmed"
        case .processing:          "orders.status.processing"
        case .shipped:             "orders.status.shipped"
        case .delivered:           "orders.status.delivered"
        case .cancelled:           "orders.status.cancelled"
        case .rejected:            "orders.status.rejected"
        case .unknown(let raw):    raw
        }
    }

    var color: Color {
        switch self {
        case .pending, .confirmed, .processing, .shipped:
            return AppColor.green
        case .delivered:
            return AppColor.green
        case .cancelled, .rejected:
            return AppColor.errorRed
        case .unknown:
            return AppColor.textSec
        }
    }

    var isActive: Bool {
        switch self {
        case .pending, .confirmed, .processing, .shipped: return true
        default: return false
        }
    }

    var isCompleted: Bool {
        if case .delivered = self { return true }
        return false
    }

    var isCancelled: Bool {
        switch self {
        case .cancelled, .rejected: return true
        default: return false
        }
    }
}
