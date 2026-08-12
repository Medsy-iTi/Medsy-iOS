//
//  ProfileSectionView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

struct ProfileSectionView: View {
    let titleKey: String
    let rows: [ProfileRowItem]
    let onSelect: (ProfileRowItem) -> Void
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titleKey.localized.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(ProfileStyle.secondaryText(isDarkMode: appSettings.isDarkMode))
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, item in
                    Button {
                        onSelect(item)
                    } label: {
                        ProfileRowView(item: item)
                    }
                    .buttonStyle(.plain)
                    .allowsHitTesting(item.isEnabled)

                    if index < rows.count - 1 {
                        Divider()
                            .background(ProfileStyle.border(isDarkMode: appSettings.isDarkMode))
                            .padding(.leading, 66)
                    }
                }
            }
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(ProfileStyle.border(isDarkMode: appSettings.isDarkMode), lineWidth: 1)
            }
        }
        .id(appSettings.isDarkMode)
    }
}

private struct ProfileRowView: View {
    let item: ProfileRowItem
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(item.iconColor.opacity(0.18))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: item.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(item.iconColor)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.titleKey.localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                if let subtitleKey = item.subtitleKey {
                    Text(subtitleKey.localized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(subtitleColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)

            if let trailingTextKey = item.trailingTextKey {
                Text(trailingTextKey.localized)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(subtitleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Image(systemName: "chevron.forward")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(item.isEnabled ? ProfileStyle.secondaryText(isDarkMode: appSettings.isDarkMode).opacity(0.72) : ProfileStyle.disabledSecondaryText(isDarkMode: appSettings.isDarkMode))
        }
        .frame(minHeight: item.subtitleKey == nil ? 64 : 68)
        .padding(.horizontal, 16)
        .padding(.vertical, item.subtitleKey == nil ? 0 : 2)
        .contentShape(Rectangle())
    }

    private var titleColor: Color {
        item.isEnabled ? ProfileStyle.primaryText(isDarkMode: appSettings.isDarkMode) : ProfileStyle.disabledPrimaryText(isDarkMode: appSettings.isDarkMode)
    }

    private var subtitleColor: Color {
        item.isEnabled ? ProfileStyle.secondaryText(isDarkMode: appSettings.isDarkMode) : ProfileStyle.disabledSecondaryText(isDarkMode: appSettings.isDarkMode)
    }
}

#Preview {
    ProfileSectionView(
        titleKey: "profile.section.account",
        rows: [
            ProfileRowItem(
                id: "personal",
                titleKey: "profile.personal_info",
                subtitleKey: "profile.personal_info.subtitle",
                iconName: "person",
                iconColor: AppColor.green
            )
        ],
        onSelect: { _ in }
    )
    .padding()
    .background(ProfileStyle.background)
}
