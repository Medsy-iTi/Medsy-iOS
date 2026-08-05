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
    case products
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
        case .products:
            "bag"
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
        case .products:
            "bag.fill"
			case .completedOrders:
				"checkmark.seal.fill"
        case .more:
            "ellipsis"
        }
    }
}
