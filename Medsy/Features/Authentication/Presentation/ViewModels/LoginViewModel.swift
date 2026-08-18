//
//  LoginViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Foundation
import Observation

@MainActor
protocol LoginViewModelProtocol: AnyObject {
    var email: String { get set }
    var password: String { get set }
    var validationMessage: String? { get }
    var state: LoginState? { get }
    var isLoading: Bool { get }
    var alertMessage: String? { get }
    @discardableResult func submit() async -> Bool
    func dismissError()
    func prepareAfterPasswordReset(email: String)
}

@MainActor
@Observable
final class LoginViewModel: LoginViewModelProtocol {
    var email = ""
    var password = ""
    private(set) var validationMessage: String?
    private(set) var state: LoginState?

    private let loginUseCase: LoginUseCaseProtocol

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
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

        if let validationError = AuthenticationInputValidator.validateLogin(
            email: email,
            password: password
        ) {
            validationMessage = validationError.message
            return false
        }

        validationMessage = nil
        state = .loading

        do {
            _ = try await loginUseCase.execute(
                input: LoginInput(
                    email: AuthenticationInputValidator.normalizedEmail(email),
                    password: password
                )
            )
            state = .success
            return true
        } catch is CancellationError {
            state = nil
            return false
        } catch let error as NetworkError {
            let message = error.errorDescription ?? "common.error".localized
            state = .error(message)
            validationMessage = message
            return false
        } catch {
            let message = error.localizedDescription
            state = .error(message)
            return false
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = nil
    }

    func prepareAfterPasswordReset(email: String) {
        self.email = email
        password = ""
        validationMessage = nil
        state = nil
    }
}
