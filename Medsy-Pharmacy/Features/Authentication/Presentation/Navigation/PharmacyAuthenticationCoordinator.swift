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
    private(set) var licenseViewModel: PharmacyLicenseViewModel?
    private let actions: PharmacyAuthenticationActions
    private let onLoginRequested: () -> Void
    private let onAuthenticated: () -> Void

    init(
        actions: PharmacyAuthenticationActions,
        onLoginRequested: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
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
                verifyAction: actions.verify,
                resendAction: actions.resendCode
            )
            path.append(.verification)
        }
    }

    func finishVerification() {
        guard registrationViewModel.accountType == .owner else {
            finishAuthentication()
            return
        }

        licenseViewModel = PharmacyLicenseViewModel(submitAction: actions.submitLicense)
        path.append(.license)
    }

    func showLogin() {
        onLoginRequested()
    }

    func finishAuthentication() {
        path.removeAll()
        onAuthenticated()
    }
}
