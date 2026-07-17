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
    private let onAuthenticated: () -> Void

    init(
        signupUseCase: SignupUseCaseProtocol,
        onAuthenticated: @escaping () -> Void
    ) {
        self.signupUseCase = signupUseCase
        self.onAuthenticated = onAuthenticated
    }

    func makeSignupViewModel() -> SignupViewModel {
        SignupViewModel(signupUseCase: signupUseCase)
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
