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

    init(signupUseCase: SignupUseCaseProtocol) {
        self.signupUseCase = signupUseCase
    }

    @MainActor
    func makeCoordinator(onAuthenticated: @escaping () -> Void) -> AuthenticationCoordinator {
        AuthenticationCoordinator(
            signupUseCase: signupUseCase,
            onAuthenticated: onAuthenticated
        )
    }
}
