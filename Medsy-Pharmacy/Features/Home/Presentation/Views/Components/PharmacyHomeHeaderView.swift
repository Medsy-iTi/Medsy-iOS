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
        ZStack {
            Text("pharmacy.home.title".localized)
                .font(PharmacyColor.sans(22, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            HStack {
                Button(action: languageManager.toggle) {
                    HStack(spacing: PharmacySpacing.xxs) {
                        Image(systemName: "globe")
                            .font(.system(size: 13, weight: .semibold))
                        Text("pharmacy.home.language".localized)
                            .font(PharmacyColor.sans(13, .semibold))
                    }
                    .foregroundStyle(PharmacyColor.primary)
                    .padding(.horizontal, PharmacySpacing.sm)
                    .frame(minHeight: 40)
                    .background(PharmacyColor.primarySoft, in: Capsule())
                }
                .buttonStyle(PharmacyPressableButtonStyle())
                .accessibilityLabel("pharmacy.home.language".localized)

                Spacer()
            }
        }
        .frame(height: 44)
    }
}
