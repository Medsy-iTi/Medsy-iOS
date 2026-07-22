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
    let loginViewModel: PharmacyLoginViewModel
    let registrationViewModel: PharmacyRegistrationViewModel
    let invitationsViewModel: PharmacyInvitationsViewModel
    private(set) var verificationViewModel: PharmacyVerificationViewModel?
    private(set) var setupViewModel: PharmacySetupViewModel?
    private(set) var destinationError: String?
    private(set) var isResolvingDestination = false
    private let actions: PharmacyAuthenticationActions
    private let locationProvider: PharmacyLocationProviding
    private let onAuthenticated: () -> Void
    private let onSignedOut: () -> Void

    init(
        actions: PharmacyAuthenticationActions,
        locationProvider: PharmacyLocationProviding,
        onAuthenticated: @escaping () -> Void,
        onSignedOut: @escaping () -> Void = {}
    ) {
        self.actions = actions
        self.locationProvider = locationProvider
        self.onAuthenticated = onAuthenticated
        self.onSignedOut = onSignedOut
        loginViewModel = PharmacyLoginViewModel(loginAction: actions.login)
        registrationViewModel = PharmacyRegistrationViewModel(registerAction: actions.register)
        invitationsViewModel = PharmacyInvitationsViewModel(
            loadAction: actions.pendingInvitations,
            acceptAction: actions.acceptInvitation,
            declineAction: actions.declineInvitation
        )
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

    func resolveAuthenticatedDestination() {
        guard !isResolvingDestination else { return }
        isResolvingDestination = true

        Task {
            defer { isResolvingDestination = false }
            do {
                let membership = try await actions.membership()
                if membership.isAssigned {
                    path.removeAll()
                    onAuthenticated()
                } else {
                    await invitationsViewModel.load(force: true)
                    prepareSetupFlow()
                }
            } catch is CancellationError {
                return
            } catch {
                destinationError = error.localizedDescription
            }
        }
    }

    func showAddPharmacy() {
        if setupViewModel == nil {
            setupViewModel = PharmacySetupViewModel(
                locationProvider: locationProvider,
                createAction: actions.createPharmacy
            )
        }
        path.append(.addPharmacy)
    }

    func showInvitations() {
        path.append(.pharmacyInvitations)
    }

    func acceptInvitation(id: Int) {
        Task {
            guard await invitationsViewModel.acceptInvitation(id: id) else { return }
            path.removeAll()
            onAuthenticated()
        }
    }

    func declineInvitation(id: Int) {
        Task {
            await invitationsViewModel.declineInvitation(id: id)
        }
    }

    func showLocationPicker() {
        path.append(.choosePharmacyLocation)
    }

    func finishPharmacyCreation() {
        path.removeAll()
        onAuthenticated()
    }

    func backToSignIn() {
        actions.signOut()
        onSignedOut()
        setupViewModel = nil
        verificationViewModel = nil
        invitationsViewModel.reset()
        path.removeAll()
    }

    func dismissDestinationError() {
        destinationError = nil
    }

    private func prepareSetupFlow() {
        setupViewModel = PharmacySetupViewModel(
            locationProvider: locationProvider,
            createAction: actions.createPharmacy
        )
        path.removeAll()
        path.append(.pharmacySetupDecision)
    }

}
