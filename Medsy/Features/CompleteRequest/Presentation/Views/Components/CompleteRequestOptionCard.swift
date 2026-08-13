//
//  CompleteRequestOptionCard.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestOptionCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let subtitle: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? accentColor : secondaryTextColor)

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(isSelected ? accentColor : secondaryTextColor)
                }

                Text(title)
                    .font(MedsyFont.bodyMedium())
                    .foregroundStyle(primaryTextColor)

                Text(subtitle)
                    .font(MedsyFont.caption())
                    .foregroundStyle(secondaryTextColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(MedsySpacing.sm)
            .frame(maxWidth: .infinity, minHeight: 138, alignment: .topLeading)
            .background(isSelected ? selectedBackgroundColor : unselectedBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: MedsyRadius.lg)
                    .stroke(isSelected ? accentColor : borderColor, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectedBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#123D2B") : Color(hex: "#D6F5E2")
    }

    private var unselectedBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#10161A") : Color(hex: "#F3F6F4")
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "#E1E6E3") : Color(hex: "#181C19")
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "#BEC9C2") : Color(hex: "#414943")
    }

    private var accentColor: Color {
        colorScheme == .dark ? Color(hex: "#27C779") : Color(hex: "#048C4E")
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color(hex: "#3C4741") : Color(hex: "#C0C9C2")
    }
}
