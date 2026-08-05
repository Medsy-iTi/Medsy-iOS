//
//  PharmacyDashboardPeriodHeader.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyDashboardPeriodHeader: View {
    let selectedPeriod: PharmacyDashboardPeriod
    let isLoading: Bool
    let onSelect: (PharmacyDashboardPeriod) -> Void

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Text("pharmacy.home.overview".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Spacer()

            if isLoading {
                ProgressView()
                    .controlSize(.small)
            }

            Menu {
                ForEach(PharmacyDashboardPeriod.allCases) { period in
                    Button {
                        onSelect(period)
                    } label: {
                        if period == selectedPeriod {
                            Label(period.titleKey.localized, systemImage: "checkmark")
                        } else {
                            Text(period.titleKey.localized)
                        }
                    }
                }
            } label: {
                HStack(spacing: PharmacySpacing.xxs) {
                    Text(selectedPeriod.titleKey.localized)
                        .font(PharmacyColor.sans(12, .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(PharmacyColor.primary)
                .padding(.horizontal, PharmacySpacing.sm)
                .padding(.vertical, PharmacySpacing.xs)
                .background(PharmacyColor.primarySoft, in: Capsule())
            }
            .accessibilityLabel("pharmacy.home.period.accessibility".localized)
        }
    }
}
