//
//  PharmacyManagementHeader.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyManagementHeader: View {
    let title: String
    var subtitle: String?
    var onBack: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            ZStack {
                Text(title)
                    .font(PharmacyColor.sans(20, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .frame(maxWidth: .infinity)

                if let onBack {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(PharmacyColor.textPrimary)
                                .frame(width: 42, height: 42)
                                .background(PharmacyColor.surface, in: Circle())
                                .overlay(Circle().stroke(PharmacyColor.border))
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
