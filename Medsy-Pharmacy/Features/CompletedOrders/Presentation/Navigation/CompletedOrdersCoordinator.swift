//
//  CompletedOrdersCoordinatorProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import Observation
import SwiftUI

enum CompletedOrdersRoute: Hashable {
    case detail(orderId: Int)
}

protocol CompletedOrdersCoordinatorProtocol: AnyObject {
    func showDetails(for order: CompletedOrder)
}

@Observable
@MainActor
final class CompletedOrdersCoordinator: CompletedOrdersCoordinatorProtocol {
    var path = NavigationPath()

    func showDetails(for order: CompletedOrder) {
        path.append(CompletedOrdersRoute.detail(orderId: order.id))
    }
}

