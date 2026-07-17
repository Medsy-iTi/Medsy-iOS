//  PharmacyAuthHeader.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct PharmacyAuthHeader: View {
    let title: String
    let subtitle: String
    var showsBrand = false

    var body: some View {
        VStack(spacing: 10) {
            if showsBrand {
                BrandMark()
            } else {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(PharmacyColor.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BrandMark: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 64))
                .foregroundStyle(PharmacyColor.primary)
                .padding(.bottom, 8)

            Text("auth.brand.name".localized)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(PharmacyColor.primary)

            Text("auth.brand.tagline".localized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(PharmacyColor.textPrimary)
        }
    }
}
