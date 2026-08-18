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
    var path: [AuthenticationRoute] = [] {
        didSet {
            if !path.contains(.resetPassword) {
                resetPasswordViewModel = nil
            }
        }
    }
    let loginViewModel: LoginViewModel
    private(set) var forgotPasswordViewModel: ForgotPasswordViewModel?
    private(set) var passwordResetOTPViewModel: PasswordResetOTPViewModel?
    private(set) var resetPasswordViewModel: ResetPasswordViewModel?
    private(set) var showsPasswordResetSuccess = false
    private let signupUseCase: SignupUseCaseProtocol
    private let verificationUseCase: VerificationUseCaseProtocol
    private let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol
    private let verifyPasswordResetUseCase: VerifyPasswordResetUseCaseProtocol
    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol
    private var passwordResetEmail: String?
    private let onAuthenticated: () -> Void

    init(
        loginUseCase: LoginUseCaseProtocol,
        signupUseCase: SignupUseCaseProtocol,
        verificationUseCase: VerificationUseCaseProtocol,
        forgotPasswordUseCase: ForgotPasswordUseCaseProtocol,
        verifyPasswordResetUseCase: VerifyPasswordResetUseCaseProtocol,
        resetPasswordUseCase: ResetPasswordUseCaseProtocol,
        onAuthenticated: @escaping () -> Void
    ) {
        self.signupUseCase = signupUseCase
        self.verificationUseCase = verificationUseCase
        self.forgotPasswordUseCase = forgotPasswordUseCase
        self.verifyPasswordResetUseCase = verifyPasswordResetUseCase
        self.resetPasswordUseCase = resetPasswordUseCase
        self.onAuthenticated = onAuthenticated
        loginViewModel = LoginViewModel(loginUseCase: loginUseCase)
    }

    func makeLoginViewModel() -> LoginViewModel {
        loginViewModel
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

    func showForgotPassword(prefilledEmail: String) {
        showsPasswordResetSuccess = false
        forgotPasswordViewModel = ForgotPasswordViewModel(
            initialEmail: prefilledEmail,
            useCase: forgotPasswordUseCase
        )
        path.append(.forgotPassword)
    }

    func showPasswordResetOTP(email: String) {
        passwordResetEmail = email
        passwordResetOTPViewModel = PasswordResetOTPViewModel(
            email: email,
            verifyUseCase: verifyPasswordResetUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase
        )
        path.append(.passwordResetOTP)
    }

    func showResetPassword(authorization: PasswordResetAuthorization) {
        resetPasswordViewModel = ResetPasswordViewModel(
            authorization: authorization,
            useCase: resetPasswordUseCase
        )
        path.append(.resetPassword)
    }

    func requestAnotherResetCode() {
        passwordResetOTPViewModel?.enableImmediateResend()
        if path.last == .resetPassword {
            path.removeLast()
        }
        resetPasswordViewModel = nil
    }

    func finishPasswordReset() {
        guard let email = passwordResetEmail else { return }
        loginViewModel.prepareAfterPasswordReset(email: email)
        clearPasswordResetFlow()
        path.removeAll()
        showsPasswordResetSuccess = true
    }

    func dismissPasswordResetSuccess() {
        showsPasswordResetSuccess = false
    }

    func finishAuthentication() {
        path.removeAll()
        onAuthenticated()
    }

    private func clearPasswordResetFlow() {
        passwordResetEmail = nil
        forgotPasswordViewModel = nil
        passwordResetOTPViewModel = nil
        resetPasswordViewModel = nil
    }
}
