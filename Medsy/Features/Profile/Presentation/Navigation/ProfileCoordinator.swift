//
//  ProfileCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation
import SwiftUI

enum ProfileRoute: Hashable {
    case favorites
    case search(String)
    case howMedsyWorks
    case helpCenter
    case reportProblem
    case myReminders
}

enum ProfilePresentation: Identifiable {
    case editProfile(openAddressPicker: Bool = false)
    case language
    case theme

    var id: String {
        switch self {
        case .editProfile(let openAddressPicker): "editProfile-\(openAddressPicker)"
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
    var path = NavigationPath()
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

    var firstName: String {
        viewModel.firstName
    }

    var lastName: String {
        viewModel.lastName
    }

    var homeAddress: String {
        viewModel.homeAddress
    }

    var dateOfBirth: Date? {
        viewModel.dateOfBirth
    }

    var phoneNumber: String {
        viewModel.phoneNumber
    }

    var email: String {
        viewModel.email
    }


    var displayHomeAddress: String {
        viewModel.displayHomeAddress
    }

	var homeLatitude: Double? {
		viewModel.homeLatitude
	}

	var homeLongitude: Double? {
		viewModel.homeLongitude
	}

    var hasDeliveryLocation: Bool {
        viewModel.hasDeliveryLocation
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

	func updateProfile(
		firstName: String,
		lastName: String,
		homeAddress: String?,
		latitude: Double?,
		longitude: Double?,
		dateOfBirth: Date?
	) async -> Bool {
		await viewModel.updateProfile(
			firstName: firstName,
			lastName: lastName,
			homeAddress: homeAddress,
			latitude: latitude,
			longitude: longitude,
			dateOfBirth: dateOfBirth
		)
	}

    func showEditProfile(openAddressPicker: Bool = false) {
        activePresentation = .editProfile(openAddressPicker: openAddressPicker)
    }
    func showFavorites() { path.append(ProfileRoute.favorites) }
    func showSearch(query: String = "") { path.append(ProfileRoute.search(query)) }
    func showHowMedsyWorks() { path.append(ProfileRoute.howMedsyWorks) }
    func showHelpCenter() { path.append(ProfileRoute.helpCenter) }
    func showReportProblem() { path.append(ProfileRoute.reportProblem) }
    func showMyReminders() { path.append(ProfileRoute.myReminders) }
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
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
