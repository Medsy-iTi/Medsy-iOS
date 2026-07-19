//
//  ProfileViewModel.swift
//  Medsy-Pharmacy
//

import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    // MARK: - View State

    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Published State

    private(set) var state: ViewState = .loading
    private(set) var profile: PharmacyProfile?

    // Logout
    var showLogoutConfirmation = false
    var isLoggingOut = false

    // Edit personal profile
    var isSaving = false
    var saveErrorMessage: String?

    // Leave pharmacy
    var showLeavePharmacyConfirmation = false
    var isLeavingPharmacy = false
    var leavePharmacyErrorMessage: String?

    // Edit pharmacy
    var isUpdatingPharmacy = false
    var updatePharmacyErrorMessage: String?

    // MARK: - Dependencies

    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let updateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol
    private let leavePharmacyUseCase: LeavePharmacyUseCaseProtocol
    private let updatePharmacyUseCase: UpdatePharmacyUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    let languageManager: LanguageManager
    private let appSettings: PharmacyAppSettings

    // MARK: - Navigation

    var onNavigate: ((ProfileRoute) -> Void)?
    var onLoggedOut: (() -> Void)?

    // MARK: - Init

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        updateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol,
        leavePharmacyUseCase: LeavePharmacyUseCaseProtocol,
        updatePharmacyUseCase: UpdatePharmacyUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        languageManager: LanguageManager,
        appSettings: PharmacyAppSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.leavePharmacyUseCase = leavePharmacyUseCase
        self.updatePharmacyUseCase = updatePharmacyUseCase
        self.logoutUseCase = logoutUseCase
        self.languageManager = languageManager
        self.appSettings = appSettings
    }

    // MARK: - Computed Props

    var currentLanguage: PharmacyAppLanguage { languageManager.currentLanguage }
    var isDarkMode: Bool { appSettings.isDarkMode }

    // MARK: - Lifecycle

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

    // MARK: - Personal Profile

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

    // MARK: - Pharmacy Actions

    func requestLeavePharmacy() {
        showLeavePharmacyConfirmation = true
    }

    func cancelLeavePharmacy() {
        showLeavePharmacyConfirmation = false
    }

    func confirmLeavePharmacy() async {
        guard let pharmacyId = profile?.pharmacyId else { return }
        isLeavingPharmacy = true
        showLeavePharmacyConfirmation = false
        leavePharmacyErrorMessage = nil
        do {
            try await leavePharmacyUseCase.execute(pharmacyId: pharmacyId)
            isLeavingPharmacy = false
            await loadProfile(showsSpinner: false)
        } catch {
            isLeavingPharmacy = false
            leavePharmacyErrorMessage = Self.userFacingMessage(for: error)
        }
    }

    func updatePharmacy(name: String?, address: String?, phoneNumber: String?) async -> Bool {
        guard let pharmacyId = profile?.pharmacyId else { return false }
        isUpdatingPharmacy = true
        updatePharmacyErrorMessage = nil
        do {
            try await updatePharmacyUseCase.execute(
                id: pharmacyId,
                name: name,
                address: address,
                phoneNumber: phoneNumber
            )
            isUpdatingPharmacy = false
            await loadProfile(showsSpinner: false)
            return true
        } catch {
            isUpdatingPharmacy = false
            updatePharmacyErrorMessage = Self.userFacingMessage(for: error)
            return false
        }
    }

    // MARK: - Navigation

    func didTapEditProfile() {
        onNavigate?(.editProfile)
    }

    func didTapEditPharmacy() {
        onNavigate?(.editPharmacy)
    }

    // MARK: - Settings

    func setLanguage(_ language: PharmacyAppLanguage) {
        languageManager.set(language)
    }

    func setTheme(isDark: Bool) {
        appSettings.isDarkMode = isDark
    }

    // MARK: - Logout

    func requestLogout() { showLogoutConfirmation = true }
    func cancelLogout() { showLogoutConfirmation = false }

    func confirmLogout() async {
        isLoggingOut = true
        await logoutUseCase.execute()
        isLoggingOut = false
        showLogoutConfirmation = false
        onLoggedOut?()
    }

    // MARK: - Helpers

    private static func userFacingMessage(for error: Error) -> String {
        "profile_generic_error".localized
    }
}
