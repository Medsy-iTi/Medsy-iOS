//
//  PharmacyAuthenticationCoordinator.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Observation

@MainActor
@Observable
final class PharmacyAuthenticationCoordinator {
    var path: [PharmacyAuthenticationRoute] = []
    let registrationViewModel: PharmacyRegistrationViewModel
    private(set) var verificationViewModel: PharmacyVerificationViewModel?
    private let actions: PharmacyAuthenticationActions
    private let onLoginRequested: () -> Void
    private let onAuthenticated: (PharmacyAccountType) -> Void

    init(
        actions: PharmacyAuthenticationActions,
        onLoginRequested: @escaping () -> Void,
        onAuthenticated: @escaping (PharmacyAccountType) -> Void
    ) {
        self.actions = actions
        self.onLoginRequested = onLoginRequested
        self.onAuthenticated = onAuthenticated
        registrationViewModel = PharmacyRegistrationViewModel(registerAction: actions.register)
    }

    func submitDetails() {
        Task {
            if await registrationViewModel.handle(.detailsSubmitted) {
                path.append(.accountType)
            }
        }
    }

    func submitRegistration() {
        Task {
            guard await registrationViewModel.handle(.registrationSubmitted) else { return }

            verificationViewModel = PharmacyVerificationViewModel(
                email: registrationViewModel.email,
                verifyAction: actions.verify
            )
            path.append(.verification)
        }
    }

    func finishVerification() {
        guard let accountType = registrationViewModel.accountType else { return }
        finishAuthentication(accountType)
    }

    func showLogin() {
        onLoginRequested()
    }

    private func finishAuthentication(_ accountType: PharmacyAccountType) {
        path.removeAll()
        onAuthenticated(accountType)
    }
}
