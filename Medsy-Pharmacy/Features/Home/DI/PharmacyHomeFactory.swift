//
//  PharmacyHomeFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyHomeFactory {
    @MainActor
    func makeView(onViewAllOrders: @escaping () -> Void) -> PharmacyHomeView {
        PharmacyHomeView(onViewAllOrders: onViewAllOrders)
    }
}
