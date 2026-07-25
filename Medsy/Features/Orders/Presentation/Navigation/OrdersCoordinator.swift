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

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
