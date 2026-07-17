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
    private let onAuthenticated: () -> Void

    init(
        actions: PharmacyAuthenticationActions,
        onAuthenticated: @escaping () -> Void
    ) {
        self.actions = actions
        self.onAuthenticated = onAuthenticated
        registrationViewModel = PharmacyRegistrationViewModel(registerAction: actions.register)
    }

    func submitDetails() {
        Task {
            if await registrationViewModel.handle(.detailsSubmitted) {
                path.append(.accountSetup)
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

    func showSignup() {
        path.append(.registrationDetails)
    }

    func showLogin() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func finishVerification() {
        path.removeAll()
        onAuthenticated()
    }

}

