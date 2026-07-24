//
//  PharmacyPrimaryButton.swift
//  Medsy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

enum PharmacyPrimaryButtonStyle {
    case filled
    case soft
}

struct PharmacyPrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading = false
    var isDisabled = false
    var style: PharmacyPrimaryButtonStyle = .filled
    var height: CGFloat = 54
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(PharmacyColor.sans(16, .bold))

                    if let systemImage {
                        HStack {
                            Spacer()
                            Image(systemName: systemImage)
                                .font(.body.weight(.semibold))
                        }
                    }
                }
            }
            .foregroundStyle(style == .filled ? .white : PharmacyColor.primary)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .padding(.horizontal, 18)
            .background(
                style == .filled ? PharmacyColor.primary : PharmacyColor.primarySoft,
                in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.45 : 1)
        .accessibilityLabel(title)
    }
}
