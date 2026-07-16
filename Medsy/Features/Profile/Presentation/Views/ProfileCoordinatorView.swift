//
//  ProfileCoordinatorView.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

struct ProfileCoordinatorView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var coordinator: ProfileCoordinator

    init(onLogout: @escaping () -> Void) {
        _coordinator = State(initialValue: ProfileCoordinator(onLogout: onLogout))
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        ProfileScreen(
            patientName: coordinator.patientName,
            phoneNumber: coordinator.phoneNumber,
            onEditProfile: coordinator.showEditProfile,
            onLanguage: coordinator.showLanguagePicker,
            onTheme: coordinator.showThemePicker,
            onLogout: coordinator.requestLogout
        )
        .sheet(item: $coordinator.activePresentation) { presentation in
            sheet(for: presentation, coordinator: coordinator)
        }
        .alert("profile.logout.title".localized, isPresented: $coordinator.showsLogoutConfirmation) {
            Button("common.cancel".localized, role: .cancel) { coordinator.cancelLogout() }
            Button("profile.logout".localized, role: .destructive) { coordinator.confirmLogout() }
        } message: {
            Text("profile.logout.message".localized)
        }
    }

    @ViewBuilder
    private func sheet(for presentation: ProfilePresentation, coordinator: ProfileCoordinator) -> some View {
        switch presentation {
        case .editProfile:
            @Bindable var coordinator = coordinator
            EditProfileScreen(
                name: $coordinator.patientName,
                phoneNumber: coordinator.phoneNumber,
                onCancel: coordinator.dismissPresentation,
                onSave: coordinator.dismissPresentation
            )
            .environment(languageManager)
            .localizedEnvironment()
        case .language:
            ProfileSelectionSheet(
                titleKey: "profile.language.title",
                messageKey: "profile.language.message",
                options: languageOptions,
                onSelect: { option in
                    if let language = AppLanguage(rawValue: option.id) {
                        withAnimation(.easeInOut(duration: 0.3)) { languageManager.set(language) }
                    }
                    coordinator.dismissPresentation()
                }
            )
            .environment(languageManager)
            .presentationDetents([.height(308)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
        case .theme:
            ProfileSelectionSheet(
                titleKey: "profile.theme.title",
                messageKey: "profile.theme.message",
                options: themeOptions,
                onSelect: { option in
                    withAnimation(.easeInOut(duration: 0.25)) { appSettings.isDarkMode = option.id == "dark" }
                    coordinator.dismissPresentation()
                }
            )
            .environment(languageManager)
            .presentationDetents([.height(308)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
        }
    }

    private var languageOptions: [ProfileSelectionOption] {
        [
            ProfileSelectionOption(id: AppLanguage.arabic.rawValue, titleKey: "language.arabic", subtitleKey: "profile.language.arabic.subtitle", iconName: "textformat", iconColor: ProfileStyle.green, isSelected: languageManager.currentLanguage == .arabic),
            ProfileSelectionOption(id: AppLanguage.english.rawValue, titleKey: "language.english", subtitleKey: "profile.language.english.subtitle", iconName: "character.book.closed", iconColor: Color(hex: "#38BDF8"), isSelected: languageManager.currentLanguage == .english)
        ]
    }

    private var themeOptions: [ProfileSelectionOption] {
        [
            ProfileSelectionOption(id: "light", titleKey: "profile.theme.light", subtitleKey: "profile.theme.light.subtitle", iconName: "sun.max", iconColor: Color(hex: "#F59E0B"), isSelected: !appSettings.isDarkMode),
            ProfileSelectionOption(id: "dark", titleKey: "profile.theme.dark", subtitleKey: "profile.theme.dark.subtitle", iconName: "moon", iconColor: Color(hex: "#A855F7"), isSelected: appSettings.isDarkMode)
        ]
    }
}
