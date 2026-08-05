//
//  OrderDateRangeFilter.swift
//  Medsy
//
//  Created by Ahmed Elkady on 24/07/2026.
//

import Foundation

enum OrderDateRangeFilter: String, CaseIterable, Identifiable {
    case anytime
    case today
    case last7Days
    case last30Days
    case last3Months
    case custom

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .anytime:     "orders.date_range.anytime"
        case .today:       "orders.date_range.today"
        case .last7Days:   "orders.date_range.last_7_days"
        case .last30Days:  "orders.date_range.last_30_days"
        case .last3Months: "orders.date_range.last_3_months"
        case .custom:      "orders.date_range.custom"
        }
    }

    func dateRange() -> (from: Date?, to: Date?) {
        let calendar = Calendar.current
        let now = Date.now
        let endOfToday = calendar.startOfDay(for: now).addingTimeInterval(86399)
        switch self {
        case .anytime:
            return (nil, nil)
        case .today:
            return (calendar.startOfDay(for: now), endOfToday)
        case .last7Days:
            return (calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: now)), endOfToday)
        case .last30Days:
            return (calendar.date(byAdding: .day, value: -30, to: calendar.startOfDay(for: now)), endOfToday)
        case .last3Months:
            return (calendar.date(byAdding: .month, value: -3, to: calendar.startOfDay(for: now)), endOfToday)
        case .custom:
            return (nil, nil)
        }
    }
}
