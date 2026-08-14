//
//  PharmacyMetricCard.swift
//  Medsy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyMetricItem: View {
    let metric: PharmacyHomeMetric

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            PharmacyIconTile(
                systemImage: metric.icon,
                tint: metric.tint,
                background: metric.tint.opacity(0.12),
                size: 38,
                iconSize: 15
            )

            VStack(alignment: .leading, spacing: 3) {
                metricValue
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(metric.titleKey.localized)
                    .font(PharmacyColor.sans(10, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .pharmacyCard(
            cornerRadius: PharmacyRadius.md,
            padding: PharmacySpacing.sm,
            elevation: .subtle
        )
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var metricValue: some View {
        switch metric.value {
        case .count(let value):
            Text(value, format: .number)
        case .revenue(let value):
            Text(
                value,
                format: .currency(code: "EGP")
                    .precision(.fractionLength(0...2))
            )
        }
    }
}
