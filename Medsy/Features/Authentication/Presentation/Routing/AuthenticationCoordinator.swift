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
    private let onAuthenticated: () -> Void

    init(onAuthenticated: @escaping () -> Void) {
        self.onAuthenticated = onAuthenticated
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
