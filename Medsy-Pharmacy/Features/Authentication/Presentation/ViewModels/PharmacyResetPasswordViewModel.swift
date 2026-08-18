//
//  PharmacyResetPasswordViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import Foundation
import Observation

enum PharmacyResetPasswordState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
protocol PharmacyResetPasswordViewModelProtocol: AnyObject {
    var newPassword: String { get set }
    var confirmedPassword: String { get set }
    var state: PharmacyResetPasswordState { get }
    var validationMessage: String? { get }
    var expirySecondsRemaining: Int { get }
    var isLoading: Bool { get }
    var isExpired: Bool { get }
    var alertMessage: String? { get }
    func submit() async -> Bool
    func dismissError()
}

@MainActor
@Observable
final class PharmacyResetPasswordViewModel: PharmacyResetPasswordViewModelProtocol {
    var newPassword = ""
    var confirmedPassword = ""
    private(set) var state: PharmacyResetPasswordState = .idle
    private(set) var validationMessage: String?
    private(set) var expirySecondsRemaining: Int

    private let authorization: PharmacyPasswordResetAuthorization
    private let resetAction: (PharmacyResetPasswordInput) async throws -> Void
    private var expiryTask: Task<Void, Never>?

    init(
        authorization: PharmacyPasswordResetAuthorization,
        resetAction: @escaping (PharmacyResetPasswordInput) async throws -> Void
    ) {
        self.authorization = authorization
        self.resetAction = resetAction
        expirySecondsRemaining = max(0, authorization.expiresInSeconds)
        startExpiryCountdown()
    }

    var isLoading: Bool { state == .loading }
    var isExpired: Bool { expirySecondsRemaining == 0 }

    var alertMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }

    func submit() async -> Bool {
        guard !isLoading else { return false }
        guard !isExpired else {
            validationMessage = "pharmacy.auth.password_reset.expired.message".localized
            return false
        }

        if let validationError = PharmacyAuthenticationInputValidator.validatePasswordReset(
            password: newPassword,
            confirmedPassword: confirmedPassword
        ) {
            validationMessage = validationError.message
            return false
        }

        validationMessage = nil
        state = .loading

        do {
            try await resetAction(
                PharmacyResetPasswordInput(
                    resetToken: authorization.resetToken,
                    newPassword: newPassword
                )
            )
            state = .success
            expiryTask?.cancel()
            return true
        } catch is CancellationError {
            state = .idle
            return false
        } catch {
            state = .error(PharmacyPasswordResetErrorMessageMapper.message(for: error))
            return false
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = .idle
    }

    private func startExpiryCountdown() {
        guard expirySecondsRemaining > 0 else { return }
        expiryTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self else { return }
                guard self.expirySecondsRemaining > 0 else { return }
                self.expirySecondsRemaining -= 1
            }
        }
    }
}
