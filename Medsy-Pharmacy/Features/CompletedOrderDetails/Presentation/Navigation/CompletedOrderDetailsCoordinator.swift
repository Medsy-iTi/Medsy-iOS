//
//  CompletedOrderDetailsCoordinator.swift
//  Medsy
//

import SwiftUI
import Observation

enum CompletedOrderDetailsRoute: Hashable {
    case detail(orderId: Int)
}

@MainActor
@Observable
final class CompletedOrderDetailsCoordinator {
    var path = NavigationPath()

    func showDetail(orderId: Int) {
        path.append(CompletedOrderDetailsRoute.detail(orderId: orderId))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
