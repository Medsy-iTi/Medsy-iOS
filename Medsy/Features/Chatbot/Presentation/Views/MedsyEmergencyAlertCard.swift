//
//  MedsyEmergencyAlertCard.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI

struct MedsyEmergencyAlertCard: View {
    var iconName: String = "exclamationmark.triangle.fill"
    var title: String
    var message: String

    var primaryActionTitle: String
    var primaryActionSubtitle: String
    var secondaryActions: [String] = []

    var accentColor: Color = MedsyTheme.default.danger
    var backgroundColor: Color = MedsyTheme.default.dangerLight

    var onPrimaryAction: () -> Void = {}
    var onSecondaryAction: (String) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(accentColor)
                    Image(systemName: iconName)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .bold))
                }
                .frame(width: 26, height: 26)

                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(accentColor)
            }

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(accentColor.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onPrimaryAction) {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(primaryActionTitle)
                            .font(.system(size: 16, weight: .bold))
                        Text(primaryActionSubtitle)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding(14)
                .background(accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            if !secondaryActions.isEmpty {
                HStack(spacing: 10) {
                    ForEach(secondaryActions, id: \.self) { action in
                        Button(action: { onSecondaryAction(action) }) {
                            Text(action)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(accentColor.opacity(0.35), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    MedsyEmergencyAlertCard(
        title: "This may be an emergency",
        message: "Chest pain spreading to the arm with sweating can be a sign of a heart attack. I can't help with this in chat — please get emergency care right now.",
        primaryActionTitle: "Call ambulance — 123",
        primaryActionSubtitle: "Egyptian Ambulance Organization",
        secondaryActions: ["Nearest hospital", "Share location"]
    )
    .padding()
}
