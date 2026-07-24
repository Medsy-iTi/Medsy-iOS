//
//  MedicineAnalyzeResultsView.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeResultsView: View {
    let imageData: Data?
    let products: [MedicineAnalyzeProductDisplay]
    let quantity: (MedicineAnalyzeProductDisplay) -> Int
    let onProductSelected: (String) -> Void
    let onAdd: (MedicineAnalyzeProductDisplay) -> Void
    let onIncrement: (MedicineAnalyzeProductDisplay) -> Void
    let onDecrement: (MedicineAnalyzeProductDisplay) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: MedsySpacing.md) {
                MedicineAnalyzeResultsSummary(
                    imageData: imageData,
                    matchCount: products.count
                )

                MedicineAnalyzeResultsGuidance()

                ForEach(products) { product in
                    MedicineAnalyzeProductCard(
                        product: product,
                        quantity: quantity(product),
                        onTap: { onProductSelected(product.id) },
                        onAdd: { onAdd(product) },
                        onIncrement: { onIncrement(product) },
                        onDecrement: { onDecrement(product) }
                    )
                }
            }
            .padding(MedsySpacing.md)
        }
    }
}
