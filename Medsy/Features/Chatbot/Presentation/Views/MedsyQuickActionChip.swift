//
//  MedsyQuickActionChip.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI

/// A rounded suggestion chip, e.g. "I have a headache — what can I take?"
/// or "Track my order". Supports a filled or outline look.
struct MedsyQuickActionChip: View {
    enum Style {
        case filled
        case outline
    }

    var iconName: String? = nil
    var title: String
    var style: Style = .outline

    var accentColor: Color = MedsyTheme.default.primary
    var backgroundColor: Color = AppColor.surface

    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let iconName {
                    Image(systemName: iconName)
                }
                Text(title)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(style == .filled ? .white : accentColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(style == .filled ? accentColor : backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(style == .outline ? accentColor.opacity(0.25) : .clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 10) {
        MedsyQuickActionChip(iconName: "heart", title: "I have a headache — what can I take?")
        HStack {
            MedsyQuickActionChip(title: "Track my order")
            MedsyQuickActionChip(title: "Reorder my usual meds")
        }
    }
    .padding()
}
