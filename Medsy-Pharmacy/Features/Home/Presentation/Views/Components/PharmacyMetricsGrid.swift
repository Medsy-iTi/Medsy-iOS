//
//  PharmacyMetricsGrid.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyMetricsGrid: View {
    let metrics: [PharmacyHomeMetric]

    private let columns = [
        GridItem(.flexible(), spacing: PharmacySpacing.xs),
        GridItem(.flexible(), spacing: PharmacySpacing.xs)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            Text("pharmacy.home.overview".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            LazyVGrid(columns: columns, spacing: PharmacySpacing.xs) {
                ForEach(metrics) { metric in
                    PharmacyMetricItem(metric: metric)
                }
            }
        }
    }
}
