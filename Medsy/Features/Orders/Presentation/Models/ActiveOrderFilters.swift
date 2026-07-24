//
//  ActiveOrderFilters.swift
//  Medsy
//
//  Created by Ahmed Elkady on 24/07/2026.
//

import Foundation

struct ActiveOrderFilters: Equatable {
    var statusFilter: OrderFilter = .all
    var dateRangeFilter: OrderDateRangeFilter = .anytime
    var customDateFrom: Date? = nil
    var customDateTo: Date? = nil
    var fulfillmentType: OrderFulfillmentType? = nil

    static let `default` = ActiveOrderFilters()

    var hasActiveFilters: Bool {
        dateRangeFilter != .anytime || fulfillmentType != nil
    }

    func resolvedDateRange() -> (from: Date?, to: Date?) {
        if dateRangeFilter == .custom {
            return (customDateFrom, customDateTo)
        }
        return dateRangeFilter.dateRange()
    }
}
