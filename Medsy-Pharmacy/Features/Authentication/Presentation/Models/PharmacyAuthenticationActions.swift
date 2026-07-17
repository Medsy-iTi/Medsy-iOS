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
        verify: { _, _ in }
    )

    static func live(
        loginUseCase: PharmacyLoginUseCaseProtocol,
        registrationUseCase: PharmacyRegistrationUseCaseProtocol,
        verificationUseCase: PharmacyVerificationUseCaseProtocol
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
            }
        )
    }
}
