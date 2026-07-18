//
//  PharmacyHomeHeaderView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyHomeHeaderView: View {
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Button(action: languageManager.toggle) {
                Text("pharmacy.home.language".localized)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .padding(.horizontal, 10)
                    .frame(height: 36)
                    .background(PharmacyColor.primarySoft, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("pharmacy.home.language".localized)

            Spacer()

            Text("pharmacy.home.title".localized)
                .font(PharmacyColor.sans(22, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Spacer()

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 40, height: 40)
                    .background(PharmacyColor.card, in: Circle())
                    .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(PharmacyColor.danger)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(PharmacyColor.card, lineWidth: 1.5))
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("pharmacy.home.notifications".localized)
        }
        .frame(height: 44)
    }
}
