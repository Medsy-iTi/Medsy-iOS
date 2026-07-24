//
//  OrdersFilter.swift
//  Medsy
//
//  Created by Ahmed Elkady on 24/07/2026.
//

import Foundation

struct OrdersFilter {
    var statuses: [OrderStatus]?
    var fulfillmentType: OrderFulfillmentType?
    var dateFrom: Date?
    var dateTo: Date?

    static let empty = OrdersFilter()
}

extension OrdersFilter: Equatable {
    static func == (lhs: OrdersFilter, rhs: OrdersFilter) -> Bool {
        let lhsStatuses = lhs.statuses?.map(\.rawValue)
        let rhsStatuses = rhs.statuses?.map(\.rawValue)
        return lhsStatuses == rhsStatuses
            && lhs.fulfillmentType == rhs.fulfillmentType
            && lhs.dateFrom == rhs.dateFrom
            && lhs.dateTo == rhs.dateTo
    }
}
