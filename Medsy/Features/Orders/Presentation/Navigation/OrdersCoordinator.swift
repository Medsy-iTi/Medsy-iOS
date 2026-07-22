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
}


@MainActor
@Observable
final class OrdersCoordinator {
    var path: [OrdersRoute] = []

    func showDetail(orderId: Int) {
        path.append(.detail(orderId: orderId))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
