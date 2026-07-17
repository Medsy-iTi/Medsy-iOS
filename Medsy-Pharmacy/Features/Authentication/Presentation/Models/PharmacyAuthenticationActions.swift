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
}

struct PharmacyAuthenticationActions {
    let register: (PharmacyRegistrationSubmission) async throws -> Void
    let verify: (String, String) async throws -> Void

    static let placeholder = PharmacyAuthenticationActions(
        register: { _ in },
        verify: { _, _ in }
    )

    static func live(
        registrationUseCase: PharmacyRegistrationUseCaseProtocol,
        verificationUseCase: PharmacyVerificationUseCaseProtocol
    ) -> PharmacyAuthenticationActions {
        PharmacyAuthenticationActions(
            register: { submission in
                try await registrationUseCase.execute(
                    input: PharmacyRegistrationInput(
                        firstName: submission.firstName,
                        lastName: submission.lastName,
                        phoneNumber: submission.phoneNumber,
                        email: submission.email,
                        password: submission.password
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
