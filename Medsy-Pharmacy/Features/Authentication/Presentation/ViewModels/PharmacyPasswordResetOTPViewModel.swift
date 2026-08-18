//
//  PharmacyPasswordResetOTPViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import Foundation
import Observation

enum PharmacyPasswordResetOTPState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

enum PharmacyPasswordResetResendState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
protocol PharmacyPasswordResetOTPViewModelProtocol: AnyObject {
    var email: String { get }
    var code: String { get }
    var state: PharmacyPasswordResetOTPState { get }
    var resendState: PharmacyPasswordResetResendState { get }
    var validationMessage: String? { get }
    var resendSecondsRemaining: Int { get }
    var isLoading: Bool { get }
    var isResending: Bool { get }
    var canResend: Bool { get }
    var alertMessage: String? { get }
    var resendConfirmationMessage: String? { get }
    func updateCode(_ value: String)
    func verify() async -> PharmacyPasswordResetAuthorization?
    func resend() async
    func enableImmediateResend()
    func dismissError()
}

@MainActor
@Observable
final class PharmacyPasswordResetOTPViewModel: PharmacyPasswordResetOTPViewModelProtocol {
    let email: String
    private(set) var code = ""
    private(set) var state: PharmacyPasswordResetOTPState = .idle
    private(set) var resendState: PharmacyPasswordResetResendState = .idle
    private(set) var validationMessage: String?
    private(set) var resendSecondsRemaining: Int

    private let verifyAction: (
        PharmacyVerifyPasswordResetInput
    ) async throws -> PharmacyPasswordResetAuthorization
    private let resendAction: (PharmacyForgotPasswordInput) async throws -> Void
    private let resendCooldownSeconds: Int
    private var cooldownTask: Task<Void, Never>?

    init(
        email: String,
        verifyAction: @escaping (
            PharmacyVerifyPasswordResetInput
        ) async throws -> PharmacyPasswordResetAuthorization,
        resendAction: @escaping (PharmacyForgotPasswordInput) async throws -> Void,
        resendCooldownSeconds: Int = 60
    ) {
        self.email = email
        self.verifyAction = verifyAction
        self.resendAction = resendAction
        self.resendCooldownSeconds = max(0, resendCooldownSeconds)
        resendSecondsRemaining = max(0, resendCooldownSeconds)
        startCooldown()
    }

    var isLoading: Bool { state == .loading }
    var isResending: Bool { resendState == .loading }
    var canResend: Bool { resendSecondsRemaining == 0 && !isLoading && !isResending }

    var alertMessage: String? {
        if case .error(let message) = state { return message }
        if case .error(let message) = resendState { return message }
        return nil
    }

    var resendConfirmationMessage: String? {
        guard resendState == .success else { return nil }
        return "pharmacy.auth.password_reset.otp.resend_success".localized
    }

    func updateCode(_ value: String) {
        code = String(value.filter(\.isNumber).prefix(6))
        validationMessage = nil
        if case .error = state { state = .idle }
        if resendState == .success { resendState = .idle }
    }

    func verify() async -> PharmacyPasswordResetAuthorization? {
        guard !isLoading, !isResending else { return nil }
        guard code.count == 6 else {
            validationMessage = "pharmacy.auth.password_reset.otp.invalid".localized
            return nil
        }

        validationMessage = nil
        state = .loading

        do {
            let authorization = try await verifyAction(
                PharmacyVerifyPasswordResetInput(email: email, otpCode: code)
            )
            state = .success
            cooldownTask?.cancel()
            return authorization
        } catch is CancellationError {
            state = .idle
            return nil
        } catch {
            state = .error(PharmacyPasswordResetErrorMessageMapper.message(for: error))
            return nil
        }
    }

    func resend() async {
        guard canResend else { return }
        resendState = .loading

        do {
            try await resendAction(PharmacyForgotPasswordInput(email: email))
            code = ""
            validationMessage = nil
            resendState = .success
            startCooldown()
        } catch is CancellationError {
            resendState = .idle
        } catch {
            resendState = .error(PharmacyPasswordResetErrorMessageMapper.message(for: error))
        }
    }

    func enableImmediateResend() {
        cooldownTask?.cancel()
        resendSecondsRemaining = 0
        resendState = .idle
    }

    func dismissError() {
        if case .error = state { state = .idle }
        if case .error = resendState { resendState = .idle }
    }

    private func startCooldown() {
        cooldownTask?.cancel()
        resendSecondsRemaining = resendCooldownSeconds
        guard resendSecondsRemaining > 0 else { return }

        cooldownTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self else { return }
                guard self.resendSecondsRemaining > 0 else { return }
                self.resendSecondsRemaining -= 1
            }
        }
    }
}
