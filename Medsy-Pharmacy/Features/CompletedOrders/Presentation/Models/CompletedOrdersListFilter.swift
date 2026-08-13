//
//  CompletedOrdersListFilter.swift
//  Medsy
//

import Foundation

enum CompletedOrdersListFilter: String, CaseIterable, Identifiable {
    case all
    case preparing
    case readyForPickup
    case outForDelivery
    case delivered

    var id: String { rawValue }

    /// The status value sent as a query parameter to the API. Nil means "no filter" (server default).
    var apiStatusValue: String? {
        switch self {
        case .all:             return nil
        case .preparing:       return "PREPARING"
        case .readyForPickup:  return "READY_FOR_PICKUP"
        case .outForDelivery:  return "OUT_FOR_DELIVERY"
        case .delivered:       return "DELIVERED"
        }
    }

    var localizedTitle: String {
        switch self {
        case .all:             return "completed_orders.filter.all".localized
        case .preparing:       return "completed_orders.filter.preparing".localized
        case .readyForPickup:  return "pharmacy.status.ready_for_pickup".localized
        case .outForDelivery:  return "completed_orders.filter.out_for_delivery".localized
        case .delivered:       return "completed_orders.filter.delivered".localized
        }
    }

    var emptyStateTitleLocalized: String {
        switch self {
        case .all:             return "completed_orders.empty.all.title".localized
        case .preparing:       return "completed_orders.empty.preparing.title".localized
        case .readyForPickup:  return "completed_orders.empty.ready_for_pickup.title".localized
        case .outForDelivery:  return "completed_orders.empty.out_for_delivery.title".localized
        case .delivered:       return "completed_orders.empty.delivered.title".localized
        }
    }

    var emptyStateMessageLocalized: String {
        switch self {
        case .all:             return "completed_orders.empty.all.message".localized
        case .preparing:       return "completed_orders.empty.preparing.message".localized
        case .readyForPickup:  return "completed_orders.empty.ready_for_pickup.message".localized
        case .outForDelivery:  return "completed_orders.empty.out_for_delivery.message".localized
        case .delivered:       return "completed_orders.empty.delivered.message".localized
        }
    }
}
