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
        switch selectedFilter {
        case .all:
            true
        case .new:
            order.status == .new
        case .preparing:
            order.status == .preparing
        case .delivered:
            order.status == .delivered
        }
    }

    private func matchesSearchText(_ order: PharmacyOrderListItem) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }

        return order.id.localizedCaseInsensitiveContains(query)
            || order.customerName.localizedCaseInsensitiveContains(query)
            || order.phoneNumber.localizedCaseInsensitiveContains(query)
    }
}

private extension PharmacyOrdersViewModel {
    static let sampleOrders = [
        PharmacyOrderListItem(
            id: "1258",
            customerName: "pharmacy.orders.customer.ahmed".localized,
            phoneNumber: "010 1234 5678",
            address: "pharmacy.orders.address.maadi".localized,
            paymentMethod: .cash,
            amount: 165,
            minutesAgo: 5,
            status: .new
        ),
        PharmacyOrderListItem(
            id: "1257",
            customerName: "pharmacy.orders.customer.menna".localized,
            phoneNumber: "010 9876 5432",
            address: "pharmacy.orders.address.nozha".localized,
            paymentMethod: .visa(lastFourDigits: "3456"),
            amount: 230,
            minutesAgo: 15,
            status: .preparing
        ),
        PharmacyOrderListItem(
            id: "1256",
            customerName: "pharmacy.orders.customer.youssef".localized,
            phoneNumber: "011 2345 6789",
            address: "pharmacy.orders.address.dar_elsalam".localized,
            paymentMethod: .cash,
            amount: 185,
            minutesAgo: 35,
            status: .delivered
        )
    ]
}
