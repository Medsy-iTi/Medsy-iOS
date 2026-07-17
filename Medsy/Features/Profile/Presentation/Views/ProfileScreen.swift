//
//  ProfileScreen.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

struct ProfileScreen: View {

    @Environment(LanguageManager.self) private var languageManager

    @ObservedObject private var appSettings = AppSettings.shared
    let patientName: String
    let phoneNumber: String
    let onEditProfile: () -> Void
    let onLanguage: () -> Void
    let onTheme: () -> Void
    let onLogout: () -> Void

    private var accountRows: [ProfileRowItem] {
        [
            ProfileRowItem(
                id: "personal",
                titleKey: "profile.personal_info",
                subtitleKey: "profile.personal_info.subtitle",
                iconName: "person",
                iconColor: ProfileStyle.green
            ),
            ProfileRowItem(
                id: "notifications",
                titleKey: "profile.notifications",
                subtitleKey: "profile.notifications.subtitle",
                iconName: "bell",
                iconColor: Color(hex: "#3B5BDB")
            ),
            ProfileRowItem(
                id: "orders",
                titleKey: "profile.order_history",
                subtitleKey: "profile.order_history.subtitle",
                iconName: "shippingbox",
                iconColor: Color(hex: "#38BDF8")
            )
        ]
    }

    private var preferenceRows: [ProfileRowItem] {
        [
            ProfileRowItem(
                id: "language",
                titleKey: "profile.language",
                iconName: "globe",
                iconColor: Color(hex: "#F59E0B"),
                trailingTextKey: languageManager.currentLanguage == .arabic ? "language.arabic" : "language.english"
            ),
            ProfileRowItem(
                id: "theme",
                titleKey: "profile.theme",
                iconName: "sun.max",
                iconColor: Color(hex: "#A855F7"),
                trailingTextKey: appSettings.isDarkMode ? "profile.theme.dark" : "profile.theme.light"
            )
        ]
    }

    private var supportRows: [ProfileRowItem] {
        [
            ProfileRowItem(
                id: "how",
                titleKey: "profile.how_it_works",
                subtitleKey: "profile.how_it_works.subtitle",
                iconName: "questionmark.circle",
                iconColor: ProfileStyle.green
            ),
            ProfileRowItem(
                id: "help",
                titleKey: "profile.help_center",
                subtitleKey: "profile.help_center.subtitle",
                iconName: "lifepreserver",
                iconColor: Color(hex: "#EC4899")
            ),
            ProfileRowItem(
                id: "report",
                titleKey: "profile.report_issue",
                subtitleKey: "profile.report_issue.subtitle",
                iconName: "exclamationmark.octagon",
                iconColor: Color(hex: "#F97316")
            )
        ]
    }

    private var aboutRows: [ProfileRowItem] {
        [
            ProfileRowItem(
                id: "about",
                titleKey: "profile.about_medsy",
                iconName: "info.circle",
                iconColor: Color(hex: "#94A3B8")
            ),
            ProfileRowItem(
                id: "terms",
                titleKey: "profile.terms",
                iconName: "doc.text",
                iconColor: Color(hex: "#94A3B8")
            ),
            ProfileRowItem(
                id: "privacy",
                titleKey: "profile.privacy",
                iconName: "shield",
                iconColor: Color(hex: "#94A3B8")
            )
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ProfileStyle.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header

                    VStack(spacing: 20) {
                        ProfileSectionView(titleKey: "profile.section.account", rows: accountRows, onSelect: handleRowSelection)
                        ProfileSectionView(titleKey: "profile.section.preferences", rows: preferenceRows, onSelect: handleRowSelection)
                        ProfileSectionView(titleKey: "profile.section.support", rows: supportRows, onSelect: handleRowSelection)
                        ProfileSectionView(titleKey: "profile.section.about", rows: aboutRows, onSelect: handleRowSelection)
                        logoutButton
                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 92)
                }
            }

        }
        .localizedEnvironment()
        .id("\(languageManager.currentLanguage.rawValue)-\(appSettings.isDarkMode)")
    }

    private var header: some View {
        VStack(spacing: 20) {
            Text("profile.title".localized)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(ProfileStyle.primaryText)
                .frame(maxWidth: .infinity)

            HStack(spacing: 16) {
                ProfileAvatarView(size: 64, showsBadge: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(patientName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ProfileStyle.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Label(phoneNumber, systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(ProfileStyle.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 21)
            .padding(.vertical, 17)
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }
            .shadow(color: ProfileStyle.green.opacity(0.08), radius: 10, y: 4)
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [ProfileStyle.headerTop, ProfileStyle.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var logoutButton: some View {
        Button {
            onLogout()
        } label: {
            Label("profile.logout".localized, systemImage: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ProfileStyle.red)
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background(ProfileStyle.redBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(ProfileStyle.redBorder, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 2) {
            Text("Medsy")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ProfileStyle.secondaryText.opacity(0.5))

            Text("profile.version".localized("1.0.0"))
                .font(.system(size: 10.5))
                .foregroundStyle(ProfileStyle.secondaryText.opacity(0.35))
        }
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
    }

    private func handleRowSelection(_ item: ProfileRowItem) {
        switch item.id {
        case "personal":
            onEditProfile()
        case "language":
            onLanguage()
        case "theme":
            onTheme()
        default:
            break
        }
    }
}

#Preview {
    ProfileScreen(
        patientName: "profile.sample.name".localized,
        phoneNumber: "+20 10 1234 5678",
        onEditProfile: {}, onLanguage: {}, onTheme: {}, onLogout: {}
    )
        .environment(LanguageManager.shared)
}
