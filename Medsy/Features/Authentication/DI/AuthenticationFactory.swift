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
    private let loginUseCase: LoginUseCaseProtocol
    private let signupUseCase: SignupUseCaseProtocol
    private let verificationUseCase: VerificationUseCaseProtocol
    private let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol
    private let verifyPasswordResetUseCase: VerifyPasswordResetUseCaseProtocol
    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol

    init(
        loginUseCase: LoginUseCaseProtocol,
        signupUseCase: SignupUseCaseProtocol,
        verificationUseCase: VerificationUseCaseProtocol,
        forgotPasswordUseCase: ForgotPasswordUseCaseProtocol,
        verifyPasswordResetUseCase: VerifyPasswordResetUseCaseProtocol,
        resetPasswordUseCase: ResetPasswordUseCaseProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.signupUseCase = signupUseCase
        self.verificationUseCase = verificationUseCase
        self.forgotPasswordUseCase = forgotPasswordUseCase
        self.verifyPasswordResetUseCase = verifyPasswordResetUseCase
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    @MainActor
    func makeCoordinator(onAuthenticated: @escaping () -> Void) -> AuthenticationCoordinator {
        AuthenticationCoordinator(
            loginUseCase: loginUseCase,
            signupUseCase: signupUseCase,
            verificationUseCase: verificationUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            verifyPasswordResetUseCase: verifyPasswordResetUseCase,
            resetPasswordUseCase: resetPasswordUseCase,
            onAuthenticated: onAuthenticated
        )
    }
}
