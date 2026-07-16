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
    var patientName = "profile.sample.name".localized
    let phoneNumber = "+20 10 1234 5678"

    private let onLogout: () -> Void

    init(onLogout: @escaping () -> Void) {
        self.onLogout = onLogout
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

