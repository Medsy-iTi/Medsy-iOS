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

    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let languageManager: LanguageManager
    private let appSettings: PharmacyAppSettings

    var onNavigate: ((ProfileRoute) -> Void)?
    var onLoggedOut: (() -> Void)?

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        languageManager: LanguageManager,
        appSettings: PharmacyAppSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.logoutUseCase = logoutUseCase
        self.languageManager = languageManager
        self.appSettings = appSettings
    }

    var languageDisplayName: String {
        languageManager.currentLanguage == .arabic ? "arabic".localized : "english".localized
    }

    var themeDisplayName: String {
        appSettings.isDarkMode ? "theme_dark".localized : "theme_light".localized
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

    func didTapSettings() {
        onNavigate?(.settings)
    }

    func didTapChangePhoneNumber() {
        onNavigate?(.changePhoneNumber)
    }

    func didTapRegisteredLocation() {
        onNavigate?(.registeredLocation)
    }

    func didTapEditDataRequest() {
        onNavigate?(.editDataRequest)
    }

    func didTapLanguage() {
        onNavigate?(.languageSelection)
    }

    func didTapTheme() {
        onNavigate?(.themeSelection)
    }

    func didTapPharmacyCard() {
        onNavigate?(.pharmacyDetails)
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
