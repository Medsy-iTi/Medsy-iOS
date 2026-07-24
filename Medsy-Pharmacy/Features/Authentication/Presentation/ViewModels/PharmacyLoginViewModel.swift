//  PharmacyLoginViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 17/07/2026.
//

import Foundation
import Observation

enum PharmacyLoginState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
@Observable
final class PharmacyLoginViewModel {
    var email = ""
    var password = ""
    private(set) var state: PharmacyLoginState = .idle
    private(set) var validationMessage: String?

    private let loginAction: (PharmacyLoginInput) async throws -> PharmacyAuthenticatedSession

    init(loginAction: @escaping (PharmacyLoginInput) async throws -> PharmacyAuthenticatedSession) {
        self.loginAction = loginAction
    }

    var isLoading: Bool {
        state == .loading
    }

    var alertMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }

    @discardableResult
    func submit() async -> Bool {
        guard !isLoading else { return false }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            validationMessage = "pharmacy.auth.validation.required".localized
            return false
        }

        guard trimmedEmail.range(of: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", options: [.regularExpression, .caseInsensitive]) != nil else {
            validationMessage = "pharmacy.auth.validation.email".localized
            return false
        }

        validationMessage = nil
        state = .loading

        do {
            _ = try await loginAction(
                PharmacyLoginInput(email: trimmedEmail.lowercased(), password: password)
            )
            state = .success
            return true
        } catch is CancellationError {
            state = .idle
            return false
        } catch {
            let message = error.localizedDescription
            state = .error(message)
            return false
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = .idle
    }
}
