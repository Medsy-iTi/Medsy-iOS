//
//  PharmacyOrdersViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyOrdersViewModel {
    var selectedFilter: PharmacyOrdersFilter = .all
    var searchText = ""

    private(set) var orders: [PharmacyOrderListItem]

    init(orders: [PharmacyOrderListItem]? = nil) {
        self.orders = orders ?? Self.sampleOrders
    }

    var visibleOrders: [PharmacyOrderListItem] {
        orders.filter { order in
            matchesSelectedFilter(order) && matchesSearchText(order)
        }
    }

    func clearSearch() {
        searchText = ""
    }

    func handleAction(for order: PharmacyOrderListItem) {
        // UI-only for now. This is the integration point for the order workflow.
    }

    private func matchesSelectedFilter(_ order: PharmacyOrderListItem) -> Bool {
        selectedFilter == .all || order.status.filter == selectedFilter
    }

    private func matchesSearchText(_ order: PharmacyOrderListItem) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }

        return order.id.localizedCaseInsensitiveContains(query)
            || order.customerNameKey.localized.localizedCaseInsensitiveContains(query)
            || order.phoneNumber.localizedCaseInsensitiveContains(query)
    }
}

private extension PharmacyOrdersViewModel {
    static let sampleOrders = [
        PharmacyOrderListItem(
            id: "1258",
            customerNameKey: "pharmacy.orders.customer.ahmed",
            phoneNumber: "010 1234 5678",
            addressKey: "pharmacy.orders.address.maadi",
            paymentKey: "pharmacy.orders.payment.cash",
            amount: "165",
            minutesAgo: 5,
            status: .new
        ),
        PharmacyOrderListItem(
            id: "1257",
            customerNameKey: "pharmacy.orders.customer.menna",
            phoneNumber: "010 9876 5432",
            addressKey: "pharmacy.orders.address.nozha",
            paymentKey: "pharmacy.orders.payment.visa",
            amount: "230",
            minutesAgo: 15,
            status: .preparing
        ),
        PharmacyOrderListItem(
            id: "1256",
            customerNameKey: "pharmacy.orders.customer.youssef",
            phoneNumber: "011 2345 6789",
            addressKey: "pharmacy.orders.address.dar_elsalam",
            paymentKey: "pharmacy.orders.payment.cash",
            amount: "185",
            minutesAgo: 35,
            status: .delivered
        )
    ]
}
