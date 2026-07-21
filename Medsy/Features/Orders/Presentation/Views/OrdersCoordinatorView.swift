//  OrdersCoordinatorView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct OrdersCoordinatorView: View {
    @State private var viewModel = PharmacyProfileViewModel()

    var body: some View {
        PharmacyProfileView(viewModel: viewModel)
    }
}
