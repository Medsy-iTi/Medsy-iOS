//
//  PharmacyOrdersFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersFactory {
    private let makeViewModel: @MainActor () -> PharmacyOrdersViewModel

    init(makeViewModel: @escaping @MainActor () -> PharmacyOrdersViewModel) {
        self.makeViewModel = makeViewModel
    }

    @MainActor
    func makeView() -> PharmacyOrdersView {
        PharmacyOrdersView(viewModel: makeViewModel())
    }
}
