//  OfferPresentationModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

enum OfferBadgeType {
    case full
    case partial
    case combined

    var title: String {
        switch self {
        case .full:
            return "offers.list.badge.full".localized
        case .partial:
            return "offers.list.badge.partial".localized
        case .combined:
            return "offers.list.badge.combined".localized
        }
    }

    var backgroundColor: Color {
        switch self {
        case .full:
            return AppColor.green
        case .partial:
            return AppColor.warningYellow
        case .combined:
            return AppColor.badgePurple
        }
    }
}

struct OfferPresentationModel: Identifiable, Hashable {
    let id: String
    let pharmacyName: String
    let subtitle: String
    let price: Int
    let badgeType: OfferBadgeType
    let isBestOption: Bool
}
