//
//  PharmacyOrderPresentation.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

extension PharmacyOrdersFilter {
    var titleKey: String {
        "pharmacy.orders.filter.\(rawValue)"
    }
}

extension PharmacyOrderListStatus {
    var titleKey: String {
        switch self {
        case .new: "pharmacy.orders.filter.new"
        case .preparing: "pharmacy.orders.filter.preparing"
        case .delivered: "pharmacy.orders.filter.delivered"
        case .completed: "pharmacy.orders.status.completed"
        case .expired: "pharmacy.orders.status.expired"
        case .pendingApproval: "pharmacy.orders.status.pending"
        }
    }

    var actionTitleKey: String {
        switch self {
        case .new: "pharmacy.orders.action.send_offer"
        case .preparing: "pharmacy.orders.action.prepare"
        case .delivered: "pharmacy.orders.action.view"
        case .completed: "pharmacy.orders.action.view"
        case .expired: "pharmacy.orders.action.expired"
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
        case .pendingApproval: PharmacyColor.primary
        }
    }

    var buttonStyle: PharmacyPrimaryButtonStyle {
        switch self {
        case .new: .filled
        case .preparing, .delivered, .completed: .soft
        case .expired, .pendingApproval: .soft
        }
    }
}

extension PharmacyOrderPaymentMethod {
    var localizedTitle: String {
        switch self {
        case .cash:
            "pharmacy.orders.payment.cash".localized
        case let .visa(lastFourDigits):
            "pharmacy.orders.payment.visa".localized(lastFourDigits)
        }
    }
}
