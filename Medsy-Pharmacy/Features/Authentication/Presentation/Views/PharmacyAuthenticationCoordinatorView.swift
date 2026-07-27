//
//  PharmacyAuthenticationCoordinatorView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyAuthenticationCoordinatorView: View {
    @State private var coordinator: PharmacyAuthenticationCoordinator

    init(coordinator: PharmacyAuthenticationCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            PharmacyLoginView(
                viewModel: coordinator.loginViewModel,
                onSignupTapped: coordinator.showSignup,
                onAuthenticated: coordinator.resolveAuthenticatedDestination
            )
            .navigationDestination(for: PharmacyAuthenticationRoute.self) { route in
                destination(for: route)
            }
        }
        .tint(PharmacyColor.primary)
        .overlay {
            if coordinator.isResolvingDestination {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("pharmacy.setup.checking_membership".localized)
                        .padding(PharmacySpacing.lg)
                        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
                }
            }
        }
        .alert(
            "common.error".localized,
            isPresented: Binding(
                get: { coordinator.destinationError != nil },
                set: { if !$0 { coordinator.dismissDestinationError() } }
            )
        ) {
            Button("common.ok".localized) { coordinator.dismissDestinationError() }
        } message: {
            if let message = coordinator.destinationError { Text(message) }
        }
    }

    @ViewBuilder
    private func destination(for route: PharmacyAuthenticationRoute) -> some View {
        switch route {
        case .login:
            PharmacyLoginView(
                viewModel: coordinator.loginViewModel,
                onSignupTapped: coordinator.showSignup,
                onAuthenticated: coordinator.resolveAuthenticatedDestination
            )
        case .registrationDetails:
            PharmacyRegistrationDetailsView(
                viewModel: coordinator.registrationViewModel,
                onContinue: coordinator.submitDetails
            )
        case .accountSetup:
            PharmacyRegistrationAccountView(
                viewModel: coordinator.registrationViewModel,
                onRegister: coordinator.submitRegistration
            )
        case .verification:
            if let viewModel = coordinator.verificationViewModel {
                PharmacyVerificationView(
                    viewModel: viewModel,
                    onVerified: coordinator.resolveAuthenticatedDestination
                )
            }
        case .pharmacySetupDecision:
            PharmacySetupDecisionView(
                invitationCount: coordinator.invitationsViewModel.pendingCount,
                onShowInvitations: coordinator.showInvitations,
                onAddPharmacy: coordinator.showAddPharmacy,
                onBackToSignIn: coordinator.backToSignIn
            )
        case .pharmacyInvitations:
            PharmacyInvitationsView(
                viewModel: coordinator.invitationsViewModel,
                onAccept: coordinator.acceptInvitation,
                onDecline: coordinator.declineInvitation
            )
        case .addPharmacy:
            if let viewModel = coordinator.setupViewModel {
                PharmacyAddView(
                    viewModel: viewModel,
                    onChooseOnMap: coordinator.showLocationPicker,
                    onCreated: coordinator.finishPharmacyCreation
                )
            }
        case .choosePharmacyLocation:
            if let viewModel = coordinator.setupViewModel {
                PharmacyMapPickerView(viewModel: viewModel)
            }
        }
    }

}
