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
            Image(systemName: metric.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(metric.tint)
                .frame(width: 34, height: 34)
                .background(metric.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))

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
        .padding(PharmacySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(PharmacyColor.mutedSurface, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous).stroke(PharmacyColor.border, lineWidth: 1))
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
