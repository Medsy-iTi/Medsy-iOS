//
//  OrderFilter.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

enum OrderFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case completed
    case cancelled

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .all:       "orders.filter.all"
        case .active:    "orders.filter.active"
        case .completed: "orders.filter.completed"
        case .cancelled: "orders.filter.cancelled"
        }
    }
}
