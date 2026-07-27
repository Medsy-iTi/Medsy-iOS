//
//  PharmacyHomeModels.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyHomeMetric: Identifiable {
    let id = UUID()
    let titleKey: String
    let value: String
    let icon: String
    let tint: Color
}

enum PharmacyOrderStatus: Equatable {
    case new
    case preparing
    case delivered
    case completed
    case expired
    case pendingApproval

    var titleKey: String {
        switch self {
        case .new: "pharmacy.home.order_new"
        case .preparing: "pharmacy.home.order_preparing"
        case .delivered: "pharmacy.home.order_delivered"
        case .completed: "pharmacy.orders.status.completed"
        case .expired: "pharmacy.orders.status.expired"
        case .pendingApproval: "pharmacy.orders.status.pending"
        }
    }

    var tint: Color {
        switch self {
        case .new: PharmacyColor.primary
        case .preparing: PharmacyColor.secondary
        case .delivered: PharmacyColor.success
        case .completed: PharmacyColor.success
        case .expired: PharmacyColor.danger
        case .pendingApproval: PharmacyColor.warning
        }
    }
}

struct PharmacyHomeOrder: Identifiable {
    let id: String
    let customerName: String
    let address: String
    let minutesAgo: Int
    let status: PharmacyOrderStatus
    let sourceOrder: PharmacyOrder

    init(order: PharmacyOrder, now: Date = Date()) {
        id = String(order.id)
        customerName = order.customerName
            ?? "pharmacy.orders.customer.fallback".localized(String(order.userId))
        address = order.deliveryAddress.isEmpty
            ? "pharmacy.orders.address.fallback".localized
            : order.deliveryAddress
        minutesAgo = max(0, Int(now.timeIntervalSince(order.date) / 60))
        status = Self.status(for: order)
        sourceOrder = order
    }

    private static func status(for order: PharmacyOrder) -> PharmacyOrderStatus {
        switch order.status {
        case .pending:
            return PharmacySubmittedOffersStore.shared.contains(order.id)
                ? .pendingApproval
                : .new
        case .accepted, .preparing, .outForDelivery:
            return .preparing
        case .delivered:
            return .delivered
        case .completed:
            return .completed
        case .cancelled, .expired, .unknown:
            return .expired
        }
    }
}
