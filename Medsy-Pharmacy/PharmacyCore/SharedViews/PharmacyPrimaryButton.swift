//  PharmacyPrimaryButton.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

enum PharmacyButtonStyleKind {
    case primary
    case secondary
}

struct PharmacyPrimaryButton: View {
    let title: String
    var systemImage: String?
    var style: PharmacyButtonStyleKind = .primary
    var isLoading = false
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .white : PharmacyColor.primary)
                } else {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if let systemImage {
                        HStack {
                            Spacer()
                            Image(systemName: systemImage)
                                .font(.body.weight(.semibold))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .padding(.horizontal, 18)
        }
        .buttonStyle(PharmacyPrimaryButtonStyle(kind: style))
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }
}

private struct PharmacyPrimaryButtonStyle: ButtonStyle {
    let kind: PharmacyButtonStyleKind
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(kind == .primary ? .white : PharmacyColor.primary)
            .background(
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .fill(kind == .primary ? PharmacyColor.primary : PharmacyColor.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .stroke(kind == .secondary ? PharmacyColor.primary : .clear, lineWidth: 1.5)
            )
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
