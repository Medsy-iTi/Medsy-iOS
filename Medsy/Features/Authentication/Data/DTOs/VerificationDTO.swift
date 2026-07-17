//
//  VerificationDTO.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

struct VerificationRequestDTO: Encodable, Equatable {
    let email: String
    let otpCode: String

    init(input: VerificationInput) {
        email = input.email
        otpCode = input.otpCode
    }
}
