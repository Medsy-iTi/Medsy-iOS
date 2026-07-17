//
//  PharmacyVerificationViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation
import Observation

enum PharmacyVerificationState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

enum PharmacyVerificationEvent {
    case codeChanged(String)
    case verificationSubmitted
    case codeResendRequested
    case errorDismissed
}

@MainActor
@Observable
final class PharmacyVerificationViewModel {
    let email: String
    var code = ""
    private(set) var state: PharmacyVerificationState = .idle
    private(set) var validationMessage: String?
    private(set) var resendSecondsRemaining = 60
    private let verifyAction: (String, String) async throws -> Void
    private let resendAction: (String) async throws -> Void
    private var countdownTask: Task<Void, Never>?

    init(
        email: String,
        verifyAction: @escaping (String, String) async throws -> Void,
        resendAction: @escaping (String) async throws -> Void
    ) {
        self.email = email
        self.verifyAction = verifyAction
        self.resendAction = resendAction
        startCountdown()
    }

    var isLoading: Bool {
        state == .loading
    }

    func handle(_ event: PharmacyVerificationEvent) async -> Bool {
        switch event {
        case let .codeChanged(value):
            code = String(value.filter { $0.isNumber }.prefix(6))
            validationMessage = nil
            return true
        case .verificationSubmitted:
            return await verify()
        case .codeResendRequested:
            return await resendCode()
        case .errorDismissed:
            state = .idle
            validationMessage = nil
            return true
        }
    }

    private func verify() async -> Bool {
        guard !isLoading else { return false }
        guard code.count == 6 else {
            validationMessage = "pharmacy.auth.validation.otp".localized
            return false
        }

        state = .loading

        do {
            try await verifyAction(email, code)
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

    private func resendCode() async -> Bool {
        guard resendSecondsRemaining == 0, !isLoading else { return false }

        state = .loading

        do {
            try await resendAction(email)
            code = ""
            validationMessage = nil
            state = .idle
            resendSecondsRemaining = 60
            startCountdown()
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

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { @MainActor [weak self] in
            while let self, resendSecondsRemaining > 0, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                resendSecondsRemaining -= 1
            }
        }
    }
}
