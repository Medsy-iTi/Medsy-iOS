//
//  ProfileSelectionSheet.swift
//  Medsy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

struct ProfileSelectionSheet: View {
    let titleKey: String
    let messageKey: String?
    let options: [ProfileSelectionOption]
    let onSelect: (ProfileSelectionOption) -> Void

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(ProfileStyle.border)
                .frame(width: 44, height: 5)
                .padding(.top, 10)

            VStack(spacing: 6) {
                Text(titleKey.localized)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ProfileStyle.primaryText)

                if let messageKey {
                    Text(messageKey.localized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(ProfileStyle.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button {
                        onSelect(option)
                    } label: {
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(option.iconColor.opacity(0.18))
                                .frame(width: 38, height: 38)
                                .overlay {
                                    Image(systemName: option.iconName)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(option.iconColor)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.titleKey.localized)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(ProfileStyle.primaryText)

                                if let subtitleKey = option.subtitleKey {
                                    Text(subtitleKey.localized)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(ProfileStyle.secondaryText)
                                }
                            }

                            Spacer(minLength: 8)

                            if option.isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(ProfileStyle.green)
                            }
                        }
                        .frame(minHeight: 64)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < options.count - 1 {
                        Divider()
                            .background(ProfileStyle.border)
                            .padding(.leading, 68)
                    }
                }
            }
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ProfileStyle.background)
        .localizedEnvironment()
    }
}

struct ProfileSelectionOption: Identifiable {
    let id: String
    let titleKey: String
    let subtitleKey: String?
    let iconName: String
    let iconColor: Color
    let isSelected: Bool

    init(
        id: String,
        titleKey: String,
        subtitleKey: String? = nil,
        iconName: String,
        iconColor: Color,
        isSelected: Bool
    ) {
        self.id = id
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.iconName = iconName
        self.iconColor = iconColor
        self.isSelected = isSelected
    }
}

#Preview {
    ProfileSelectionSheet(
        titleKey: "profile.language.title",
        messageKey: "profile.language.message",
        options: [
            ProfileSelectionOption(
                id: "ar",
                titleKey: "language.arabic",
                iconName: "textformat",
                iconColor: ProfileStyle.green,
                isSelected: true
            )
        ],
        onSelect: { _ in }
    )
    .environment(LanguageManager.shared)
}
