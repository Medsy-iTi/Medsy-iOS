//
//  OrdersAssembly.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

struct OrdersAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(OrderHistoryViewModel.self) { _ in
            MainActor.assumeIsolated {
                OrderHistoryViewModel()
            }
        }

        container.register(OrderDetailViewModel.self) { _ in
            MainActor.assumeIsolated {
                OrderDetailViewModel()
            }
        }
    }
}
