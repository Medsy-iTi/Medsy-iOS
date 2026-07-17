//  PharmacyLoginViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyLoginViewModel {
    var email = ""
    var password = ""
    private(set) var validationMessage: String?
    private(set) var isLoading = false
    private(set) var alertMessage: String?

    private let loginUseCase: PharmacyLoginUseCaseProtocol

    init() {
        self.loginUseCase = PharmacyAppAssembler.shared.container.resolve(PharmacyLoginUseCaseProtocol.self)
    }

    init(loginUseCase: PharmacyLoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    func submit() async -> Bool {
        guard !isLoading else { return false }

        guard !email.isEmpty, !password.isEmpty else {
            validationMessage = "auth.validation.required".localized
            return false
        }

        guard isValidEmail(email) else {
            validationMessage = "auth.validation.invalid_email".localized
            return false
        }

        validationMessage = nil
        isLoading = true
        alertMessage = nil

        do {
            _ = try await loginUseCase.execute(
                input: LoginInput(email: email, password: password)
            )
            isLoading = false
            return true
        } catch is CancellationError {
            isLoading = false
            return false
        } catch let error as NetworkError {
            isLoading = false
            alertMessage = error.errorDescription ?? "common.error".localized
            return false
        } catch {
            isLoading = false
            alertMessage = error.localizedDescription
            return false
        }
    }

    func dismissError() {
        alertMessage = nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
