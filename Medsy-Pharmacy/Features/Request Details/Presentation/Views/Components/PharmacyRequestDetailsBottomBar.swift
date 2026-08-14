//
//  PharmacyRequestDetailsBottomBar.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsBottomBar: View {
    var isSubmitting: Bool = false
    var buttonTitle: String
    var isButtonDisabled: Bool
    let onSendOffer: () -> Void

    var body: some View {
        PharmacyPrimaryButton(
            title: buttonTitle,
            systemImage: isButtonDisabled ? "checkmark.circle.fill" : "paperplane.fill",
            isLoading: isSubmitting,
            isDisabled: isButtonDisabled,
            action: onSendOffer
        )
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
        .background(PharmacyColor.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(PharmacyColor.border)
                .frame(height: 1)
        }
        .shadow(
            color: .black.opacity(PharmacyAppSettings.shared.isDarkMode ? 0.28 : 0.08),
            radius: 14,
            y: -4
        )
    }
}
