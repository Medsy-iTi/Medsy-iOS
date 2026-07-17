//
//  VerificationViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Observation

@MainActor
protocol VerificationViewModelProtocol: AnyObject {
    var code: String { get }
    var validationMessage: String? { get }
    var state: VerificationState? { get }
    var isLoading: Bool { get }
    var alertMessage: String? { get }
    func updateCode(_ value: String)
    func clearValidationMessage()
    @discardableResult func submit(email: String) async -> Bool
    func dismissError()
}

@MainActor
@Observable
final class VerificationViewModel: VerificationViewModelProtocol {
    var code = ""
    private(set) var validationMessage: String?
    private(set) var state: VerificationState?

    private let verificationUseCase: VerificationUseCaseProtocol

    init(verificationUseCase: VerificationUseCaseProtocol) {
        self.verificationUseCase = verificationUseCase
    }

    var isLoading: Bool {
        state == .loading
    }

    var alertMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }

    func updateCode(_ value: String) {
        code = String(value.filter(\.isNumber).prefix(6))
        validationMessage = nil
    }

    func clearValidationMessage() {
        validationMessage = nil
    }

    func submit(email: String) async -> Bool {
        guard !isLoading else { return false }
        guard code.count == 6 else {
            validationMessage = "auth.verification.invalid_code".localized
            return false
        }

        validationMessage = nil
        state = .loading

        do {
            _ = try await verificationUseCase.execute(
                input: VerificationInput(email: email, otpCode: code)
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
            validationMessage = message
            return false
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = nil
    }
}
