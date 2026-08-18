//
//  ForgotPasswordViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import Observation

enum ForgotPasswordState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
protocol ForgotPasswordViewModelProtocol: AnyObject {
    var email: String { get set }
    var state: ForgotPasswordState { get }
    var validationMessage: String? { get }
    var isLoading: Bool { get }
    var alertMessage: String? { get }
    func submit() async -> String?
    func dismissError()
}

@MainActor
@Observable
final class ForgotPasswordViewModel: ForgotPasswordViewModelProtocol {
    var email: String
    private(set) var state: ForgotPasswordState = .idle
    private(set) var validationMessage: String?

    private let useCase: ForgotPasswordUseCaseProtocol

    init(initialEmail: String, useCase: ForgotPasswordUseCaseProtocol) {
        email = initialEmail
        self.useCase = useCase
    }

    var isLoading: Bool { state == .loading }

    var alertMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }

    func submit() async -> String? {
        guard !isLoading else { return nil }

        let normalizedEmail = AuthenticationInputValidator.normalizedEmail(email)
        guard !normalizedEmail.isEmpty else {
            validationMessage = AuthenticationValidationError.emailRequired.message
            return nil
        }
        guard AuthenticationInputValidator.isValidEmail(normalizedEmail) else {
            validationMessage = AuthenticationValidationError.invalidEmail.message
            return nil
        }

        validationMessage = nil
        state = .loading

        do {
            try await useCase.execute(input: ForgotPasswordInput(email: normalizedEmail))
            email = normalizedEmail
            state = .success
            return normalizedEmail
        } catch is CancellationError {
            state = .idle
            return nil
        } catch {
            let message = PasswordResetErrorMessageMapper.message(for: error)
            state = .error(message)
            return nil
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = .idle
    }
}
