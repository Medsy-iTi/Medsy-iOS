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
    case processing
    case shipped
    case delivered
    case cancelled
    case rejected
    case unknown(String)

    var rawValue: String {
        switch self {
        case .pending:          return "PENDING"
        case .confirmed:        return "CONFIRMED"
        case .processing:       return "PROCESSING"
        case .shipped:          return "SHIPPED"
        case .delivered:        return "DELIVERED"
        case .cancelled:        return "CANCELLED"
        case .rejected:         return "REJECTED"
        case .unknown(let raw): return raw
        }
    }

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
}

struct OrderEntity: Identifiable {
    let id: Int
    let orderNumber: Int
    let pharmacyName: String
    let status: OrderStatus
    let date: Date
    let totalPrice: Double
    let itemCount: Int
}
