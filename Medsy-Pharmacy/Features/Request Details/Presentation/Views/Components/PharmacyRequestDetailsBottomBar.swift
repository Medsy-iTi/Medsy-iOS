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
        VStack(spacing: PharmacySpacing.xs) {
            Button(action: onSendOffer) {
                HStack(spacing: 8) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(buttonTitle)
                            .font(PharmacyColor.sans(16, .bold))
                        Image(systemName: isButtonDisabled ? "checkmark.circle.fill" : "paperplane.fill")
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isButtonDisabled ? PharmacyColor.textSecondary : PharmacyColor.primary, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isButtonDisabled)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
        .background(PharmacyColor.bg)
    }
}
