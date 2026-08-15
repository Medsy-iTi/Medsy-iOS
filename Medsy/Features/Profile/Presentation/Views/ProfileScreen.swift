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
    let email: String
    let homeAddress: String
    let dateOfBirthText: String
    let hasDeliveryLocation: Bool
    let state: ProfileViewState
    let onRetry: () -> Void
    let onEditProfile: () -> Void
    let onAddDeliveryLocation: () -> Void
    let onLanguage: () -> Void
    let onTheme: () -> Void
    let onOrders: () -> Void
    let onFavorites: () -> Void
    let onHowMedsyWorks: () -> Void
    let onHelpCenter: () -> Void
    let onReportProblem: () -> Void
    let onReminders: () -> Void
    let onLogout: () -> Void

    private var profileDetails: [ProfileDetailItem] {
        [
            ProfileDetailItem(titleKey: "profile.email", value: email.isEmpty ? "profile.not_set".localized : email, iconName: "envelope", iconColor: Color(hex: "#3B5BDB")),
            ProfileDetailItem(titleKey: "profile.phone", value: phoneNumber.isEmpty ? "profile.not_set".localized : phoneNumber, iconName: "phone", iconColor: ProfileStyle.green),
            ProfileDetailItem(titleKey: "profile.home_address", value: homeAddress, iconName: "house", iconColor: Color(hex: "#F97316")),
            ProfileDetailItem(titleKey: "profile.date_of_birth", value: dateOfBirthText, iconName: "calendar", iconColor: Color(hex: "#38BDF8"))
        ]
    }

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
                id: "favorites",
                titleKey: "profile.favorites",
                subtitleKey: "profile.favorites.subtitle",
                iconName: "heart.fill",
                iconColor: Color(hex: "#EC4899")
            ),
            ProfileRowItem(
                id: "orders",
                titleKey: "profile.order_history",
                subtitleKey: "profile.order_history.subtitle",
                iconName: "shippingbox",
                iconColor: Color(hex: "#38BDF8")
            ),
            ProfileRowItem(
                id: "reminders",
                titleKey: "profile.reminders",
                subtitleKey: "profile.reminders.subtitle",
                iconName: "bell.fill",
                iconColor: Color(hex: "#F59E0B")
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
                trailingTextKey: themeTrailingTextKey
            )
        ]
    }

    private var themeTrailingTextKey: String {
        switch appSettings.themeMode {
        case .system:
            return "profile.theme.system"
        case .light:
            return "profile.theme.light"
        case .dark:
            return "profile.theme.dark"
        }
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

    private var isProfileLoading: Bool {
        state == .idle || state == .loading
    }

    private var shouldShowDeliveryLocationCard: Bool {
        !hasDeliveryLocation
    }


    var body: some View {
        ZStack(alignment: .bottom) {
            ProfileStyle.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header

                    VStack(spacing: 20) {
                        if shouldShowDeliveryLocationCard {
                            ProfileDeliveryLocationCard(onTap: onAddDeliveryLocation)
                        }
                        stateContent
                        ProfileSectionView(titleKey: "profile.section.account", rows: accountRows, onSelect: handleRowSelection)
                        ProfileSectionView(titleKey: "profile.section.preferences", rows: preferenceRows, onSelect: handleRowSelection)
                        ProfileSectionView(titleKey: "profile.section.support", rows: supportRows, onSelect: handleRowSelection)

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

            if isProfileLoading {
                ProfileHeaderLoadingSkeleton()
                    .padding(.horizontal, 20)
            } else {
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

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .idle, .loading:
            ProfileDetailsLoadingSkeleton()
        case .loaded:
            ProfileDetailsCard(items: profileDetails)
        case .failed(let message):
            ProfileErrorCard(message: message, onRetry: onRetry)
        }
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
        case "orders":
            onOrders()
        case "favorites":
            onFavorites()
        case "reminders":
            onReminders()
        case "how":
            onHowMedsyWorks()
        case "help":
            onHelpCenter()
        case "report":
            onReportProblem()
        default:
            break
        }
    }
}

#Preview {
    ProfileScreen(
        patientName: "profile.sample.name".localized,
        phoneNumber: "+20 10 1234 5678",
        email: "customer@dawanow.com",
        homeAddress: "Cairo, Egypt",
        dateOfBirthText: "Jun 15, 1995",
        hasDeliveryLocation: true,
        state: .loaded,
        onRetry: {},
        onEditProfile: {}, onAddDeliveryLocation: {}, onLanguage: {}, onTheme: {}, onOrders: {}, onFavorites: {},
        onHowMedsyWorks: {}, onHelpCenter: {}, onReportProblem: {}, onReminders: {}, onLogout: {}
    )
        .environment(LanguageManager.shared)
}

private struct ProfileDetailItem: Identifiable {
    let id = UUID()
    let titleKey: String
    let value: String
    let iconName: String
    let iconColor: Color
}

private struct ProfileDetailsCard: View {
    let items: [ProfileDetailItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("profile.section.details".localized.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(ProfileStyle.secondaryText)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    ProfileDetailRow(item: item)

                    if index < items.count - 1 {
                        Divider()
                            .background(ProfileStyle.border)
                            .padding(.leading, 56)
                    }
                }
            }
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }
        }
    }
}

private struct ProfileDeliveryLocationCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(ProfileStyle.green.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(ProfileStyle.green)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text("profile.delivery_location.title".localized)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(ProfileStyle.primaryText)

                    Text("profile.delivery_location.subtitle".localized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(ProfileStyle.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ProfileStyle.primaryText)
                    .flipsForRightToLeftLayoutDirection(true)
            }
            .padding(14)
            .background(ProfileStyle.green.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(ProfileStyle.green.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ProfileDetailRow: View {
    let item: ProfileDetailItem

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(item.iconColor.opacity(0.16))
                .frame(width: 34, height: 34)
                .overlay {
                    Image(systemName: item.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(item.iconColor)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.titleKey.localized)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ProfileStyle.secondaryText)

                Text(item.value)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(ProfileStyle.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct ProfileErrorCard: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(ProfileStyle.red)

                Text("profile.load_failed".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ProfileStyle.primaryText)
            }

            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ProfileStyle.secondaryText)
                .lineLimit(3)

            Button("common.retry".localized) {
                onRetry()
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(ProfileStyle.green)
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(ProfileStyle.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ProfileStyle.redBorder, lineWidth: 1)
        }
    }
}
