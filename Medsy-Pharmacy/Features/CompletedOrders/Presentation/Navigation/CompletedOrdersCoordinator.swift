//
//  CompletedOrdersCoordinatorProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import Observation

protocol CompletedOrdersCoordinatorProtocol: Coordinator {
    func showDetails(for order: CompletedOrder)
}

@Observable
@MainActor
final class CompletedOrdersCoordinator: CompletedOrdersCoordinatorProtocol {


    func showDetails(for order: CompletedOrder) {


        print("CompletedOrdersCoordinator.showDetails(for:) — order #\(order.id) — details screen not built yet")
    }
}

