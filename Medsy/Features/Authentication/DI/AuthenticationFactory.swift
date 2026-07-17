//
//  AuthenticationFactory.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

/// Composition boundary for the authentication presentation flow.
/// Future login and registration use cases are injected here.
struct AuthenticationFactory {
    private let signupUseCase: SignupUseCaseProtocol
    private let verificationUseCase: VerificationUseCaseProtocol

    init(
        signupUseCase: SignupUseCaseProtocol,
        verificationUseCase: VerificationUseCaseProtocol
    ) {
        self.signupUseCase = signupUseCase
        self.verificationUseCase = verificationUseCase
    }

    @MainActor
    func makeCoordinator(onAuthenticated: @escaping () -> Void) -> AuthenticationCoordinator {
        AuthenticationCoordinator(
            signupUseCase: signupUseCase,
            verificationUseCase: verificationUseCase,
            onAuthenticated: onAuthenticated
        )
    }
}
