//
//  OrdersFilter.swift
//  Medsy
//
//  Created by Ahmed Elkady on 24/07/2026.
//

import Foundation

struct OrdersFilter: Equatable {
    var statuses: [OrderStatus]?
    var fulfillmentType: OrderFulfillmentType?
    var dateFrom: Date?
    var dateTo: Date?

    static let empty = OrdersFilter()
}
