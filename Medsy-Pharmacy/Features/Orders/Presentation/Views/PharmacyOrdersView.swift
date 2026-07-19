//
//  PharmacyOrdersView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersView: View {
    @State private var viewModel: PharmacyOrdersViewModel

    init(viewModel: PharmacyOrdersViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: PharmacySpacing.sm) {
                PharmacyOrdersHeaderView()
                PharmacyOrdersFilterBar(selection: $viewModel.selectedFilter)
                PharmacyOrderSearchField(
                    text: $viewModel.searchText,
                    onClear: viewModel.clearSearch
                )

                if viewModel.visibleOrders.isEmpty {
                    PharmacyOrdersEmptyView()
                } else {
                    ForEach(viewModel.visibleOrders) { order in
                        PharmacyOrderItem(
                            order: order,
                            onAction: { viewModel.handleAction(for: order) }
                        )
                    }
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.top, PharmacySpacing.sm)
            .padding(.bottom, PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
    }
}

#Preview("Orders") {
    PharmacyOrdersView(viewModel: PharmacyOrdersViewModel())
        .environment(LanguageManager.shared)
        .pharmacyLocalizedEnvironment()
}
