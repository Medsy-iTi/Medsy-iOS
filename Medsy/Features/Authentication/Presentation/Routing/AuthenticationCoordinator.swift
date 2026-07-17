//
//  AuthenticationCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class AuthenticationCoordinator {
    var path: [AuthenticationRoute] = []
    private let signupUseCase: SignupUseCaseProtocol
    private let verificationUseCase: VerificationUseCaseProtocol
    private let onAuthenticated: () -> Void

    init(
        signupUseCase: SignupUseCaseProtocol,
        verificationUseCase: VerificationUseCaseProtocol,
        onAuthenticated: @escaping () -> Void
    ) {
        self.signupUseCase = signupUseCase
        self.verificationUseCase = verificationUseCase
        self.onAuthenticated = onAuthenticated
    }

    func makeSignupViewModel() -> SignupViewModel {
        SignupViewModel(signupUseCase: signupUseCase)
    }

    func makeVerificationViewModel() -> VerificationViewModel {
        VerificationViewModel(verificationUseCase: verificationUseCase)
    }

    func showSignup() {
        path.append(.signup)
    }

    func showLogin() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func showVerification(email: String) {
        path.append(.verification(email: email))
    }

    func finishAuthentication() {
        path.removeAll()
        onAuthenticated()
    }
}
