//
//  ProfilePreferencesSection.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfilePreferencesSection: View {
    let currentLanguage: PharmacyAppLanguage
    let themePreference: PharmacyThemePreference
    let onLanguageChange: (PharmacyAppLanguage) -> Void
    let onThemeChange: (PharmacyThemePreference) -> Void

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
            ForEach(PharmacyThemePreference.allCases) { preference in
                themeButton(preference)
            }
        } label: {
            ProfileMenuRow(
                icon: "moon.stars.fill",
                iconTint: PharmacyColor.secondary,
                title: "theme_title".localized,
                subtitle: themePreference.localizationKey.localized
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

    private func themeButton(_ preference: PharmacyThemePreference) -> some View {
        Button {
            onThemeChange(preference)
        } label: {
            HStack {
                Text(preference.localizationKey.localized)
                if themePreference == preference {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
