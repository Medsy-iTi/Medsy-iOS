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
    case errorDismissed
}

@MainActor
@Observable
final class PharmacyVerificationViewModel {
    let email: String
    var code = ""
    private(set) var state: PharmacyVerificationState = .idle
    private(set) var validationMessage: String?
    private let verifyAction: (String, String) async throws -> Void

    init(
        email: String,
        verifyAction: @escaping (String, String) async throws -> Void
    ) {
        self.email = email
        self.verifyAction = verifyAction
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

}
