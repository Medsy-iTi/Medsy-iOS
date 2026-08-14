//
//  CompleteRequestAddressOptionCard.swift
//  Medsy
//
//  Created by Ahmed Elkady on 14/08/2026.
//

import SwiftUI

struct CompleteRequestAddressOptionCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let subtitle: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack(spacing: MedsySpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? accentColor : secondaryTextColor)
                    .frame(width: 30, height: 30)
                    .background(isSelected ? selectedIconBackgroundColor : iconBackgroundColor)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                    Text(title)
                        .font(MedsyFont.bodyMedium())
                        .foregroundStyle(primaryTextColor)

                    Text(subtitle)
                        .font(MedsyFont.caption())
                        .foregroundStyle(secondaryTextColor)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(isSelected ? accentColor : secondaryTextColor)
            }

            if isSelected {
                content()
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        )
                    )
            }
        }
        .padding(MedsySpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? selectedBackgroundColor : backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(isSelected ? accentColor : borderColor, lineWidth: isSelected ? 2 : 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .onTapGesture(perform: action)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#10161A") : Color(hex: "#FFFFFF")
    }

    private var selectedBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#123D2B") : Color(hex: "#D6F5E2")
    }

    private var iconBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#182126") : Color(hex: "#EEF3F0")
    }

    private var selectedIconBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#164F35") : Color(hex: "#BFEED4")
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
