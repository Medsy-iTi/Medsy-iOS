//
//  OrdersCoordinator.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI
import Observation


enum OrdersRoute: Hashable {
    case detail(orderId: Int)
    case payment(orderId: Int)
    case pharmacyProfile(id: Int)
    case search(String)
}


@MainActor
@Observable
final class OrdersCoordinator {
    var path = NavigationPath()

    func showDetail(orderId: Int) {
        path.append(OrdersRoute.detail(orderId: orderId))
    }

    func showSearch(query: String = "") {
        path.append(OrdersRoute.search(query))
    }

    func showPayment(orderId: Int) {
        path.append(OrdersRoute.payment(orderId: orderId))
    }

    func showPharmacyProfile(id: Int) {
        path.append(OrdersRoute.pharmacyProfile(id: id))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
