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

    // Presence (on-duty / heartbeat)
    private(set) var isOnDuty = false
    var isTogglingPresence = false
    var presenceErrorMessage: String?
    
    // Presence Toast
    var showPresenceToast = false
    var presenceToastMessage: String?

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

    // Delete pharmacy
    var showDeletePharmacyConfirmation = false
    var isDeletingPharmacy = false
    var deletePharmacyErrorMessage: String?

    // Edit pharmacy
    var isUpdatingPharmacy = false
    var updatePharmacyErrorMessage: String?

    // Pharmacist team management (admin)
    var selectedPharmacist: PharmacistMember?
    var showRemovePharmacistConfirmation = false
    var isRemovingPharmacist = false
    var removePharmacistErrorMessage: String?
    var isUpdatingPharmacist = false
    var updatePharmacistErrorMessage: String?

    // Invite pharmacist (admin)
    var inviteEmail = ""
    var isInvitingPharmacist = false
    var inviteErrorMessage: String?

    // MARK: - Dependencies

    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let updateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol
    private let leavePharmacyUseCase: LeavePharmacyUseCaseProtocol
    private let updatePharmacyUseCase: UpdatePharmacyUseCaseProtocol
    private let deletePharmacyUseCase: DeletePharmacyUseCaseProtocol
    private let removePharmacistUseCase: RemovePharmacistUseCaseProtocol
    private let invitePharmacistUseCase: InvitePharmacistUseCaseProtocol
    private let updatePharmacistUseCase: UpdatePharmacistUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let goOnDutyUseCase: GoOnDutyUseCaseProtocol
    private let goOffDutyUseCase: GoOffDutyUseCaseProtocol
    let languageManager: LanguageManager
    private let appSettings: PharmacyAppSettings

    // MARK: - Heartbeat

    /// Periodic task that keeps the server informed the pharmacist is still on-duty.
    private var heartbeatTask: Task<Void, Never>?

    // MARK: - Navigation

    var onNavigate: ((ProfileRoute) -> Void)?
    var onPresentSheet: ((ProfileSheet) -> Void)?
    var onLoggedOut: (() -> Void)?

    // MARK: - Init

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        updateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol,
        leavePharmacyUseCase: LeavePharmacyUseCaseProtocol,
        updatePharmacyUseCase: UpdatePharmacyUseCaseProtocol,
        deletePharmacyUseCase: DeletePharmacyUseCaseProtocol,
        removePharmacistUseCase: RemovePharmacistUseCaseProtocol,
        invitePharmacistUseCase: InvitePharmacistUseCaseProtocol,
        updatePharmacistUseCase: UpdatePharmacistUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        goOnDutyUseCase: GoOnDutyUseCaseProtocol,
        goOffDutyUseCase: GoOffDutyUseCaseProtocol,
        languageManager: LanguageManager,
        appSettings: PharmacyAppSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.leavePharmacyUseCase = leavePharmacyUseCase
        self.updatePharmacyUseCase = updatePharmacyUseCase
        self.deletePharmacyUseCase = deletePharmacyUseCase
        self.removePharmacistUseCase = removePharmacistUseCase
        self.invitePharmacistUseCase = invitePharmacistUseCase
        self.updatePharmacistUseCase = updatePharmacistUseCase
        self.logoutUseCase = logoutUseCase
        self.goOnDutyUseCase = goOnDutyUseCase
        self.goOffDutyUseCase = goOffDutyUseCase
        self.languageManager = languageManager
        self.appSettings = appSettings
    }

    // MARK: - Computed Props

    var currentLanguage: PharmacyAppLanguage { languageManager.currentLanguage }
    var isDarkMode: Bool { appSettings.isDarkMode }

    var pharmacyMembers: [PharmacistMember] {
        profile?.pharmacyMembers ?? []
    }

    var pharmacistCount: Int {
        pharmacyMembers.count
    }

    var pharmacistCountLabel: String {
        String(format: "profile.pharmacists_count".localized, pharmacistCount)
    }

    /// Non-admin members the current admin can remove or edit.
    var manageablePharmacists: [PharmacistMember] {
        guard let profile, profile.isPharmacyAdmin else { return [] }
        return pharmacyMembers.filter { member in
            member.id != Int(profile.id) && !member.isAdmin
        }
    }

    func canManage(_ member: PharmacistMember) -> Bool {
        guard let profile, profile.isPharmacyAdmin else { return false }
        return member.id != Int(profile.id) && !member.isAdmin
    }

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
            await logoutAndNotify()
        } catch {
            isLeavingPharmacy = false
            leavePharmacyErrorMessage = Self.userFacingMessage(for: error)
        }
    }

    func requestDeletePharmacy() {
        showDeletePharmacyConfirmation = true
    }

    func cancelDeletePharmacy() {
        showDeletePharmacyConfirmation = false
    }

    func confirmDeletePharmacy() async {
        guard let pharmacyId = profile?.pharmacyId else { return }
        isDeletingPharmacy = true
        showDeletePharmacyConfirmation = false
        deletePharmacyErrorMessage = nil
        do {
            try await deletePharmacyUseCase.execute(id: pharmacyId)
            await logoutAndNotify()
        } catch {
            isDeletingPharmacy = false
            deletePharmacyErrorMessage = Self.userFacingMessage(for: error)
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

    // MARK: - Pharmacist Team (Admin)

    func didTapPharmacistOptions(_ member: PharmacistMember) {
        guard canManage(member) else { return }
        selectedPharmacist = member
        onPresentSheet?(.pharmacistOptions(member))
    }

    func didTapViewPharmacistProfile(_ member: PharmacistMember) {
        onNavigate?(.pharmacistProfile(member))
    }

    func didTapEditPharmacist(_ member: PharmacistMember) {
        selectedPharmacist = member
        onPresentSheet?(.editPharmacist(member))
    }

    func requestRemovePharmacist(_ member: PharmacistMember) {
        guard canManage(member) else { return }
        selectedPharmacist = member
        // Show confirmation dialog instead of sheet
        showRemovePharmacistConfirmation = true
    }

    func cancelRemovePharmacist() {
        selectedPharmacist = nil
    }

    func confirmRemovePharmacist() async -> Bool {
        guard
            let member = selectedPharmacist,
            let pharmacyId = profile?.pharmacyId
        else { return false }

        isRemovingPharmacist = true
        removePharmacistErrorMessage = nil
        do {
            try await removePharmacistUseCase.execute(
                pharmacistId: member.id,
                pharmacyId: pharmacyId
            )
            isRemovingPharmacist = false
            selectedPharmacist = nil
            await loadProfile(showsSpinner: false)
            return true
        } catch {
            isRemovingPharmacist = false
            removePharmacistErrorMessage = Self.userFacingMessage(for: error)
            return false
        }
    }

    func updatePharmacist(
        id: Int,
        email: String,
        firstName: String,
        lastName: String,
        homeAddress: String?,
        dateOfBirth: Date?
    ) async -> Bool {
        isUpdatingPharmacist = true
        updatePharmacistErrorMessage = nil
        do {
            try await updatePharmacistUseCase.execute(
                id: id,
                email: email.isEmpty ? nil : email,
                firstName: firstName.isEmpty ? nil : firstName,
                lastName: lastName.isEmpty ? nil : lastName,
                homeAddress: homeAddress,
                dateOfBirth: dateOfBirth
            )
            isUpdatingPharmacist = false
            selectedPharmacist = nil
            await loadProfile(showsSpinner: false)
            return true
        } catch {
            isUpdatingPharmacist = false
            updatePharmacistErrorMessage = Self.userFacingMessage(for: error)
            return false
        }
    }

    // MARK: - Invite Pharmacist (Admin)

    func sendInvitation() async -> Bool {
        guard
            let pharmacyId = profile?.pharmacyId,
            profile?.isPharmacyAdmin == true
        else { return false }

        let trimmedEmail = inviteEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            inviteErrorMessage = "pharmacy_invite.validation_email".localized
            return false
        }

        isInvitingPharmacist = true
        inviteErrorMessage = nil
        do {
            let invitation = try await invitePharmacistUseCase.execute(
                pharmacyId: pharmacyId,
                email: trimmedEmail
            )
            isInvitingPharmacist = false
            inviteEmail = ""
            onNavigate?(.inviteSuccess(InviteSuccessInfo(
                email: invitation.invitedEmail,
                pharmacyName: invitation.pharmacyName
            )))
            return true
        } catch {
            isInvitingPharmacist = false
            inviteErrorMessage = Self.userFacingMessage(for: error)
            return false
        }
    }

    func resetInviteForm() {
        inviteEmail = ""
        inviteErrorMessage = nil
    }

    // MARK: - Navigation

    func didTapPersonalProfile() {
        onNavigate?(.personalProfileDetail)
    }

    func didTapPharmacyProfile() {
        onNavigate?(.pharmacyDetail)
    }

    func didTapPharmacistsList() {
        onNavigate?(.pharmacistsList)
    }

    func didTapInvitePharmacist() {
        resetInviteForm()
        onNavigate?(.invitePharmacist)
    }

    func didTapEditProfile() {
        onPresentSheet?(.editProfile)
    }

    func didTapEditPharmacy() {
        onPresentSheet?(.editPharmacy)
    }

    func didTapSettings() {
        onNavigate?(.settings)
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
        await logoutAndNotify()
    }

    private func logoutAndNotify() async {
        await logoutUseCase.execute()
        isLoggingOut = false
        isLeavingPharmacy = false
        isDeletingPharmacy = false
        showLogoutConfirmation = false
        onLoggedOut?()
    }

    // MARK: - Presence

    /// Toggles on-duty / off-duty state, calling the appropriate API endpoint
    /// and starting/stopping the heartbeat task.
    func togglePresence() async {
        isTogglingPresence = true
        presenceErrorMessage = nil
        do {
            let status: PresenceStatus
            if isOnDuty {
                status = try await goOffDutyUseCase.execute()
                stopHeartbeat()
            } else {
                status = try await goOnDutyUseCase.execute()
                startHeartbeat()
            }
            isOnDuty = status.onDuty
            presenceToastMessage = isOnDuty ? "profile.presence.toast.on".localized : "profile.presence.toast.off".localized
            showPresenceToast = true
            Task {
                try? await Task.sleep(for: .seconds(3))
                showPresenceToast = false
            }
        } catch {
            presenceErrorMessage = "profile.presence.error".localized
        }
        isTogglingPresence = false
    }

    // MARK: - Helpers

    private static func userFacingMessage(for error: Error) -> String {
        "profile_generic_error".localized
    }

    // MARK: - Heartbeat

    /// Starts a repeating 30-second heartbeat that keeps the pharmacist's
    /// on-duty status alive on the server.
    private func startHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled, self?.isOnDuty == true else { break }
                _ = try? await self?.goOnDutyUseCase.execute()
            }
        }
    }

    /// Cancels the running heartbeat task.
    private func stopHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
    }
}
