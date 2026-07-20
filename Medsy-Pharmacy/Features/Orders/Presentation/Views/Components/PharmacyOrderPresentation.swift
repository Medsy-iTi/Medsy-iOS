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
        }
    }

    var actionTitleKey: String {
        switch self {
        case .new: "pharmacy.orders.action.accept"
        case .preparing: "pharmacy.orders.action.prepare"
        case .delivered: "pharmacy.orders.action.view"
        }
    }

    var tint: Color {
        switch self {
        case .new: PharmacyColor.primary
        case .preparing: PharmacyColor.secondary
        case .delivered: PharmacyColor.success
        }
    }

    var buttonStyle: PharmacyPrimaryButtonStyle {
        switch self {
        case .new: .filled
        case .preparing, .delivered: .soft
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
