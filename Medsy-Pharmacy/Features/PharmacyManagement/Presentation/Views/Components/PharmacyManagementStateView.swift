//
//  PharmacyManagementStateView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyManagementStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .frame(width: 104, height: 104)
                .background(PharmacyColor.primarySoft, in: Circle())

            VStack(spacing: PharmacySpacing.xs) {
                Text(title)
                    .font(PharmacyColor.sans(22, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Text(message)
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            PharmacyPrimaryButton(title: actionTitle, systemImage: "arrow.forward", action: action)
        }
        .padding(PharmacySpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
