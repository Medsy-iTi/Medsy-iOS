//
//  PharmacyTab.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

enum PharmacyTab: String, CaseIterable, Identifiable {
    case home
    case orders
    case chatBot
	case completedOrders
    case more

    var id: String {
        rawValue
    }

    var titleKey: String {
        "pharmacy.tab.\(rawValue)"
    }

    var icon: String {
        switch self {
        case .home:
            "house"
        case .orders:
            "list.clipboard"
        case .chatBot:
            "sparkles"
			case .completedOrders:
			"checkmark.seal"
        case .more:
            "ellipsis"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:
            "house.fill"
        case .orders:
            "list.clipboard.fill"
        case .chatBot:
            "sparkles"
			case .completedOrders:
				"checkmark.seal.fill"
        case .more:
            "ellipsis"
        }
    }
}
