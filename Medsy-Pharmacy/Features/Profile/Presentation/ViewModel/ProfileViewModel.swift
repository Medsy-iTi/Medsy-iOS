//
//  ProfileViewModel.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Published UI State

    private(set) var state: ViewState = .loading
    private(set) var profile: PharmacyProfile?
    var showLogoutConfirmation: Bool = false
    var isLoggingOut: Bool = false
    var isSaving: Bool = false
    var saveErrorMessage: String?

    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let updateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let languageManager: LanguageManager
    private let appSettings: PharmacyAppSettings

    var onNavigate: ((ProfileRoute) -> Void)?
    var onLoggedOut: (() -> Void)?

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        updateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        languageManager: LanguageManager,
        appSettings: PharmacyAppSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.logoutUseCase = logoutUseCase
        self.languageManager = languageManager
        self.appSettings = appSettings
    }

    var currentLanguage: PharmacyAppLanguage {
        languageManager.currentLanguage
    }

    var languageDisplayName: String {
        currentLanguage == .arabic ? "arabic".localized : "english".localized
    }

    var isDarkMode: Bool {
        appSettings.isDarkMode
    }

    var themeDisplayName: String {
        isDarkMode ? "theme_dark".localized : "theme_light".localized
    }

    func setLanguage(_ language: PharmacyAppLanguage) {
        languageManager.set(language)
    }

    func setTheme(isDark: Bool) {
        appSettings.isDarkMode = isDark
    }

    func onAppear() async {
        guard profile == nil else { return }
        await loadProfile()
    }

    func refresh() async {
        await loadProfile(showsSpinner: false)
    }

    private func loadProfile(showsSpinner: Bool = true) async {
        if showsSpinner { state = .loading }
        do {
            let profile = try await getProfileUseCase.execute()
            self.profile = profile
            self.state = .loaded
        } catch {
            if case NetworkError.unauthorized = error {
                onLoggedOut?()
                return
            }
            self.state = .error(Self.userFacingMessage(for: error))
        }
    }

    func updateProfile(homeAddress: String?, dateOfBirth: Date?) async -> Bool {
        guard let profile, let id = Int(profile.id) else { return false }
        isSaving = true
        saveErrorMessage = nil
        do {
            try await updateProfileUseCase.execute(
                id: id,
                email: profile.email,
                firstName: profile.firstName,
                lastName: profile.lastName,
                homeAddress: homeAddress,
                dateOfBirth: dateOfBirth
            )
            isSaving = false
            await loadProfile(showsSpinner: false)
            return true
        } catch {
            isSaving = false
            saveErrorMessage = Self.userFacingMessage(for: error)
            return false
        }
    }

    func didTapSettings() {
        onNavigate?(.settings)
    }





    func didTapPharmacyCard() {
        onNavigate?(.pharmacyDetails)
    }

    func didTapEditProfile() {
        onNavigate?(.editProfile)
    }

    func requestLogout() {
        showLogoutConfirmation = true
    }

    func cancelLogout() {
        showLogoutConfirmation = false
    }

    func confirmLogout() async {
        isLoggingOut = true
        await logoutUseCase.execute()
        isLoggingOut = false
        showLogoutConfirmation = false
        onLoggedOut?()
    }

    private static func userFacingMessage(for error: Error) -> String {
        "profile_generic_error".localized
    }
}
