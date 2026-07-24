//
//  ProfileViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation
import Observation

enum ProfileViewState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var profile: CustomerProfile?
    private(set) var state: ProfileViewState = .idle
    private(set) var isSaving = false
    private(set) var saveErrorMessage: String?

    private let getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol
    private let updateCustomerProfileUseCase: UpdateCustomerProfileUseCaseProtocol

    nonisolated init(
        getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol,
        updateCustomerProfileUseCase: UpdateCustomerProfileUseCaseProtocol
    ) {
        self.getCustomerProfileUseCase = getCustomerProfileUseCase
        self.updateCustomerProfileUseCase = updateCustomerProfileUseCase
    }

    var displayName: String {
        guard let profile, !profile.fullName.isEmpty else {
            return "profile.sample.name".localized
        }
        return profile.fullName
    }

    var phoneNumber: String {
        profile?.phoneNumber ?? ""
    }

    var email: String {
        profile?.email ?? ""
    }

    var homeAddress: String {
        profile?.homeAddress ?? ""
    }

    var displayHomeAddress: String {
        homeAddress.isEmpty ? "profile.not_set".localized : homeAddress
    }
	var homeLatitude: Double? {
		profile?.homeLatitude
	}

	var homeLongitude: Double? {
		profile?.homeLongitude
	}


    var dateOfBirth: Date? {
        profile?.dateOfBirth
    }

    var displayDateOfBirth: String {
        guard let dateOfBirth else {
            return "profile.not_set".localized
        }

        return ProfileViewModel.dateFormatter.string(from: dateOfBirth)
    }

    var canSave: Bool {
        !isSaving
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func loadProfile() async {
        guard state != .loading else { return }
        state = .loading
        saveErrorMessage = nil

        do {
            profile = try await getCustomerProfileUseCase.execute()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func refreshProfile() async {
        state = .idle
        await loadProfile()
    }

    func updateProfile(
		homeAddress: String?,
		latitude: Double?,
		longitude: Double?,
		dateOfBirth: Date?) async -> Bool {
        guard canSave else { return false }
        isSaving = true
        saveErrorMessage = nil

        let trimmedAddress = homeAddress?.trimmingCharacters(in: .whitespacesAndNewlines)
		let normalizedAddress = trimmedAddress?.isEmpty == true ? nil : trimmedAddress
		let input = UpdateCustomerProfileInput(
			homeAddress: normalizedAddress,
			homeLatitude: normalizedAddress == nil ? nil : latitude,
			homeLongitude: normalizedAddress == nil ? nil : longitude,
			dateOfBirth: dateOfBirth
		)
        do {
            profile = try await updateCustomerProfileUseCase.execute(input: input)
            state = .loaded
            isSaving = false
            return true
        } catch {
            saveErrorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }
}
