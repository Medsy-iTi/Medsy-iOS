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
        LazyVGrid(columns: columns, spacing: PharmacySpacing.xs) {
            ForEach(metrics) { metric in
                PharmacyMetricItem(metric: metric)
            }
        }
    }
}
