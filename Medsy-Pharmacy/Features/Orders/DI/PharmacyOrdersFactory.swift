//
//  PharmacyOrdersFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersFactory {
    @MainActor
    func makeView() -> PharmacyOrdersView {
        PharmacyOrdersView()
    }
}
