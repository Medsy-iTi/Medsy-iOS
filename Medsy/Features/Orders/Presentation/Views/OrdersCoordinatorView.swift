//
//  OrdersCoordinatorView.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import SwiftUI

struct OrdersCoordinatorView: View {
    @State private var viewModel = DIContainer.shared.resolve(PharmacyProfileViewModel.self)

    var body: some View {
        PharmacyProfileView(viewModel: viewModel)
    }
}
