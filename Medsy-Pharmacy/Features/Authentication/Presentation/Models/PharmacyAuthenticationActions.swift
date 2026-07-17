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
    let accountType: PharmacyAccountType
}

struct PharmacyAuthenticationActions {
    let register: (PharmacyRegistrationSubmission) async throws -> Void
    let verify: (String, String) async throws -> Void
    let resendCode: (String) async throws -> Void
    let submitLicense: (PharmacyLicenseDocument) async throws -> Void

    static let placeholder = PharmacyAuthenticationActions(
        register: { _ in },
        verify: { _, _ in },
        resendCode: { _ in },
        submitLicense: { _ in }
    )
}
