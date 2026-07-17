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
    case accountTypeSelected(PharmacyAccountType)
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
    var accountType: PharmacyAccountType?
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
        case let .accountTypeSelected(accountType):
            self.accountType = accountType
            validationMessage = nil
            return true
        case .registrationSubmitted:
            return await submitRegistration()
        case .errorDismissed:
            state = .idle
            validationMessage = nil
            return true
        }
    }

    private func validateDetails() -> Bool {
        let fields = [firstName, lastName, phoneNumber, email, password, confirmedPassword]
        guard fields.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            validationMessage = "pharmacy.auth.validation.required".localized
            return false
        }

        guard email.range(of: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", options: [.regularExpression, .caseInsensitive]) != nil else {
            validationMessage = "pharmacy.auth.validation.email".localized
            return false
        }

        guard phoneNumber.range(of: "^01[0125][0-9]{8}$", options: .regularExpression) != nil else {
            validationMessage = "pharmacy.auth.validation.phone".localized
            return false
        }

        guard password == confirmedPassword else {
            validationMessage = "pharmacy.auth.validation.password_mismatch".localized
            return false
        }

        validationMessage = nil
        return true
    }

    private func submitRegistration() async -> Bool {
        guard !isLoading else { return false }
        guard validateDetails() else { return false }
        guard accountType != nil else {
            validationMessage = "pharmacy.auth.validation.account_type".localized
            return false
        }

        state = .loading

        do {
            try await registerAction(
                PharmacyRegistrationSubmission(
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: phoneNumber,
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                    password: password
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
