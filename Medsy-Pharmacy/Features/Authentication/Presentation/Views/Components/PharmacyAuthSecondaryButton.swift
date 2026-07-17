//  PharmacyAuthSecondaryButton.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct PharmacyAuthSecondaryButton: View {
    let title: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                        .stroke(PharmacyColor.border, lineWidth: 1)
                }
        }
        .accessibilityLabel(title)
    }
}
