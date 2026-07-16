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
    case customers
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
        case .customers:
            "person"
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
        case .customers:
            "person.fill"
        case .more:
            "ellipsis"
        }
    }
}
