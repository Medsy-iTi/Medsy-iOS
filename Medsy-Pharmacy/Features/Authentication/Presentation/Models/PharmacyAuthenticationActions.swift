//
//  PharmacyAuthenticationActions.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

struct PharmacyRegistrationSubmission: Equatable {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let password: String
    let homeAddress: String
    let dateOfBirth: Date
}

struct PharmacyAuthenticationActions {
    let login: (PharmacyLoginInput) async throws -> PharmacyAuthenticatedSession
    let register: (PharmacyRegistrationSubmission) async throws -> Void
    let verify: (String, String) async throws -> Void
    let requestPasswordReset: (PharmacyForgotPasswordInput) async throws -> Void
    let verifyPasswordReset: (
        PharmacyVerifyPasswordResetInput
    ) async throws -> PharmacyPasswordResetAuthorization
    let resetPassword: (PharmacyResetPasswordInput) async throws -> Void
    let membership: () async throws -> PharmacyMembership
    let pendingInvitations: () async throws -> [PendingPharmacyInvitation]
    let acceptInvitation: (Int) async throws -> PendingPharmacyInvitation
    let declineInvitation: (Int) async throws -> PendingPharmacyInvitation
    let createPharmacy: (CreatePharmacyInput) async throws -> CreatedPharmacy
    let signOut: () -> Void

    static let placeholder = PharmacyAuthenticationActions(
        login: { _ in
            PharmacyAuthenticatedSession(
                accessToken: "",
                refreshToken: "",
                user: PharmacyAuthenticatedUser(
                    id: 0,
                    email: "",
                    firstName: "",
                    lastName: "",
                    role: "",
                    homeAddress: nil,
                    dateOfBirth: nil
                )
            )
        },
        register: { _ in },
        verify: { _, _ in },
        requestPasswordReset: { _ in },
        verifyPasswordReset: { _ in
            PharmacyPasswordResetAuthorization(resetToken: "", expiresInSeconds: 600)
        },
        resetPassword: { _ in },
        membership: { PharmacyMembership(pharmacyID: nil, isAdmin: false) },
        pendingInvitations: { [] },
        acceptInvitation: { id in
            PendingPharmacyInvitation(
                id: id,
                pharmacyID: 1,
                pharmacyName: "",
                pharmacistID: 1,
                pharmacistFirstName: "",
                pharmacistLastName: "",
                status: .accepted,
                createdAt: nil
            )
        },
        declineInvitation: { id in
            PendingPharmacyInvitation(
                id: id,
                pharmacyID: 1,
                pharmacyName: "",
                pharmacistID: 1,
                pharmacistFirstName: "",
                pharmacistLastName: "",
                status: .declined,
                createdAt: nil
            )
        },
        createPharmacy: { input in
            CreatedPharmacy(
                id: 1,
                name: input.name,
                latitude: input.location.latitude,
                longitude: input.location.longitude,
                address: input.location.address,
                phoneNumber: input.phoneNumber
            )
        },
        signOut: {}
    )

    static func live(
        loginUseCase: PharmacyLoginUseCaseProtocol,
        registrationUseCase: PharmacyRegistrationUseCaseProtocol,
        verificationUseCase: PharmacyVerificationUseCaseProtocol,
        forgotPasswordUseCase: PharmacyForgotPasswordUseCaseProtocol,
        verifyPasswordResetUseCase: PharmacyVerifyPasswordResetUseCaseProtocol,
        resetPasswordUseCase: PharmacyResetPasswordUseCaseProtocol,
        membershipUseCase: GetPharmacyMembershipUseCaseProtocol,
        invitationUseCase: ManagePharmacyInvitationsUseCaseProtocol,
        createPharmacyUseCase: CreatePharmacyUseCaseProtocol,
        tokenStore: TokenStoreProtocol
    ) -> PharmacyAuthenticationActions {
        PharmacyAuthenticationActions(
            login: { input in
                try await loginUseCase.execute(input: input)
            },
            register: { submission in
                try await registrationUseCase.execute(
                    input: PharmacyRegistrationInput(
                        firstName: submission.firstName,
                        lastName: submission.lastName,
                        phoneNumber: submission.phoneNumber,
                        email: submission.email,
                        password: submission.password,
                        homeAddress: submission.homeAddress,
                        dateOfBirth: submission.dateOfBirth
                    )
                )
            },
            verify: { email, code in
                _ = try await verificationUseCase.execute(
                    input: PharmacyVerificationInput(
                        email: email,
                        otpCode: code
                    )
                )
            },
            requestPasswordReset: { input in
                try await forgotPasswordUseCase.execute(input: input)
            },
            verifyPasswordReset: { input in
                try await verifyPasswordResetUseCase.execute(input: input)
            },
            resetPassword: { input in
                try await resetPasswordUseCase.execute(input: input)
            },
            membership: {
                try await membershipUseCase.execute()
            },
            pendingInvitations: {
                try await invitationUseCase.getPendingInvitations()
            },
            acceptInvitation: { id in
                try await invitationUseCase.acceptInvitation(id: id)
            },
            declineInvitation: { id in
                try await invitationUseCase.declineInvitation(id: id)
            },
            createPharmacy: { input in
                try await createPharmacyUseCase.execute(input: input)
            },
            signOut: {
                try? tokenStore.clearTokens()
            }
        )
    }
}
