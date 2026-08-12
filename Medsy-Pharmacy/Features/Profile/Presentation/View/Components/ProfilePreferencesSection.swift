//
//  ProfilePreferencesSection.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfilePreferencesSection: View {
    let currentLanguage: PharmacyAppLanguage
    let isDarkMode: Bool
    let onLanguageChange: (PharmacyAppLanguage) -> Void
    let onThemeChange: (Bool) -> Void

    var body: some View {
        ProfileSectionContainer {
            languageMenu

            ProfileRowDivider()

            themeMenu
        }
    }

    private var languageMenu: some View {
        Menu {
            languageButton(.english, titleKey: "english")
            languageButton(.arabic, titleKey: "arabic")
        } label: {
            ProfileMenuRow(
                icon: "globe",
                title: "language_title".localized,
                subtitle: currentLanguage == .arabic
                    ? "arabic".localized
                    : "english".localized
            )
        }
    }

    private var themeMenu: some View {
        Menu {
            themeButton(isDark: false, titleKey: "theme_light")
            themeButton(isDark: true, titleKey: "theme_dark")
        } label: {
            ProfileMenuRow(
                icon: "moon.stars.fill",
                iconTint: PharmacyColor.secondary,
                title: "theme_title".localized,
                subtitle: isDarkMode
                    ? "theme_dark".localized
                    : "theme_light".localized
            )
        }
    }

    private func languageButton(
        _ language: PharmacyAppLanguage,
        titleKey: String
    ) -> some View {
        Button {
            onLanguageChange(language)
        } label: {
            HStack {
                Text(titleKey.localized)
                if currentLanguage == language {
                    Image(systemName: "checkmark")
                }
            }
        }
    }

    private func themeButton(isDark: Bool, titleKey: String) -> some View {
        Button {
            onThemeChange(isDark)
        } label: {
            HStack {
                Text(titleKey.localized)
                if isDarkMode == isDark {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
