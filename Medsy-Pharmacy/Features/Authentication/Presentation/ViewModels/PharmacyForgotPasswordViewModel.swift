//
//  PharmacyForgotPasswordViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import Observation

enum PharmacyForgotPasswordState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
protocol PharmacyForgotPasswordViewModelProtocol: AnyObject {
    var email: String { get set }
    var state: PharmacyForgotPasswordState { get }
    var validationMessage: String? { get }
    var isLoading: Bool { get }
    var alertMessage: String? { get }
    func submit() async -> String?
    func dismissError()
}

@MainActor
@Observable
final class PharmacyForgotPasswordViewModel: PharmacyForgotPasswordViewModelProtocol {
    var email: String
    private(set) var state: PharmacyForgotPasswordState = .idle
    private(set) var validationMessage: String?

    private let requestAction: (PharmacyForgotPasswordInput) async throws -> Void

    init(
        initialEmail: String,
        requestAction: @escaping (PharmacyForgotPasswordInput) async throws -> Void
    ) {
        email = initialEmail
        self.requestAction = requestAction
    }

    var isLoading: Bool { state == .loading }

    var alertMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }

    func submit() async -> String? {
        guard !isLoading else { return nil }

        let normalizedEmail = PharmacyAuthenticationInputValidator.normalizedEmail(email)
        guard !normalizedEmail.isEmpty else {
            validationMessage = PharmacyAuthenticationValidationError.emailRequired.message
            return nil
        }
        guard PharmacyAuthenticationInputValidator.isValidEmail(normalizedEmail) else {
            validationMessage = PharmacyAuthenticationValidationError.invalidEmail.message
            return nil
        }

        validationMessage = nil
        state = .loading

        do {
            try await requestAction(PharmacyForgotPasswordInput(email: normalizedEmail))
            email = normalizedEmail
            state = .success
            return normalizedEmail
        } catch is CancellationError {
            state = .idle
            return nil
        } catch {
            state = .error(PharmacyPasswordResetErrorMessageMapper.message(for: error))
            return nil
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = .idle
    }
}
