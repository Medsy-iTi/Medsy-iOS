//
//  ProfileCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation
import SwiftUI

enum ProfilePresentation: Identifiable {
    case editProfile
    case language
    case theme

    var id: String {
        switch self {
        case .editProfile: "editProfile"
        case .language: "language"
        case .theme: "theme"
        }
    }

    var height: CGFloat? {
        switch self {
        case .editProfile: nil
        case .language, .theme: 308
        }
    }
}

@MainActor
@Observable
final class ProfileCoordinator {
    var activePresentation: ProfilePresentation?
    var showsLogoutConfirmation = false
    let viewModel: ProfileViewModel

    private let onLogout: () -> Void

    init(viewModel: ProfileViewModel, onLogout: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onLogout = onLogout
    }

    var patientName: String {
        viewModel.displayName
    }

    var phoneNumber: String {
        viewModel.phoneNumber
    }

    var email: String {
        viewModel.email
    }

    var homeAddress: String {
        viewModel.homeAddress
    }

    var displayHomeAddress: String {
        viewModel.displayHomeAddress
    }

    var dateOfBirth: Date? {
        viewModel.dateOfBirth
    }

    var displayDateOfBirth: String {
        viewModel.displayDateOfBirth
    }

    var state: ProfileViewState {
        viewModel.state
    }

    var isSaving: Bool {
        viewModel.isSaving
    }

    var saveErrorMessage: String? {
        viewModel.saveErrorMessage
    }

    func loadProfile() async {
        await viewModel.loadProfile()
    }

    func refreshProfile() async {
        await viewModel.refreshProfile()
    }

    func updateProfile(homeAddress: String?, dateOfBirth: Date?) async -> Bool {
        await viewModel.updateProfile(homeAddress: homeAddress, dateOfBirth: dateOfBirth)
    }

    func showEditProfile() { activePresentation = .editProfile }
    func showLanguagePicker() { activePresentation = .language }
    func showThemePicker() { activePresentation = .theme }
    func dismissPresentation() { activePresentation = nil }
    func requestLogout() { showsLogoutConfirmation = true }
    func cancelLogout() { showsLogoutConfirmation = false }

    func confirmLogout() {
        showsLogoutConfirmation = false
        activePresentation = nil
        onLogout()
    }
}
