//
//  PharmacyRegistrationViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation
import Observation

enum PharmacyRegistrationState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

enum PharmacyRegistrationEvent {
    case detailsSubmitted
    case registrationSubmitted
    case errorDismissed
}

@MainActor
@Observable
final class PharmacyRegistrationViewModel {
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var email = ""
    var password = ""
    var confirmedPassword = ""
    var homeAddress = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    private(set) var state: PharmacyRegistrationState = .idle
    private(set) var validationMessage: String?
    private let registerAction: (PharmacyRegistrationSubmission) async throws -> Void

    init(registerAction: @escaping (PharmacyRegistrationSubmission) async throws -> Void) {
        self.registerAction = registerAction
    }

    var isLoading: Bool {
        state == .loading
    }

    func handle(_ event: PharmacyRegistrationEvent) async -> Bool {
        switch event {
        case .detailsSubmitted:
            return validateDetails()
        case .registrationSubmitted:
            return await submitRegistration()
        case .errorDismissed:
            state = .idle
            validationMessage = nil
            return true
        }
    }

    private func validateDetails() -> Bool {
        if let validationError = PharmacyAuthenticationInputValidator.validateRegistrationDetails(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            email: email,
            dateOfBirth: dateOfBirth
        ) {
            validationMessage = validationError.message
            return false
        }

        validationMessage = nil
        return true
    }

    private func validateAccountSetup() -> Bool {
        if let validationError = PharmacyAuthenticationInputValidator.validateAccountSetup(
            password: password,
            confirmedPassword: confirmedPassword,
            homeAddress: homeAddress
        ) {
            validationMessage = validationError.message
            return false
        }

        validationMessage = nil
        return true
    }

    private func submitRegistration() async -> Bool {
        guard !isLoading else { return false }
        guard validateDetails() else { return false }
        guard validateAccountSetup() else { return false }

        state = .loading

        do {
            try await registerAction(
                PharmacyRegistrationSubmission(
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: phoneNumber,
                    email: PharmacyAuthenticationInputValidator.normalizedEmail(email),
                    password: password,
                    homeAddress: homeAddress.trimmingCharacters(in: .whitespacesAndNewlines),
                    dateOfBirth: dateOfBirth
                )
            )
            state = .success
            return true
        } catch is CancellationError {
            state = .idle
            return false
        } catch {
            let message = error.localizedDescription
            state = .error(message)
            validationMessage = message
            return false
        }
    }
}
