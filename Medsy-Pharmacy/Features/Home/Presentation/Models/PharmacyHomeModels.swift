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

enum PharmacyOrderStatus {
    case new
    case preparing
    case delivered

    var titleKey: String {
        switch self {
        case .new: "pharmacy.home.order_new"
        case .preparing: "pharmacy.home.order_preparing"
        case .delivered: "pharmacy.home.order_delivered"
        }
    }

    var tint: Color {
        switch self {
        case .new: PharmacyColor.primary
        case .preparing: PharmacyColor.secondary
        case .delivered: PharmacyColor.success
        }
    }
}

struct PharmacyHomeOrder: Identifiable {
    let id: String
    let customerNameKey: String
    let addressKey: String
    let minutesAgo: Int
    let status: PharmacyOrderStatus
}
