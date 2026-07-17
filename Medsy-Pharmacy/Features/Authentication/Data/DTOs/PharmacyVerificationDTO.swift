//
//  PharmacyVerificationDTO.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyVerificationRequestDTO: Encodable, Equatable {
    let email: String
    let otpCode: String

    init(input: PharmacyVerificationInput) {
        email = input.email
        otpCode = input.otpCode
    }
}
