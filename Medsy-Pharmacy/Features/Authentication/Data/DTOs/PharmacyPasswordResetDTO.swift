//
//  PharmacyPasswordResetDTO.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

struct PharmacyForgotPasswordRequestDTO: Encodable, Equatable {
    let email: String

    init(input: PharmacyForgotPasswordInput) {
        email = input.email
    }
}

struct PharmacyVerifyPasswordResetRequestDTO: Encodable, Equatable {
    let email: String
    let otpCode: String

    init(input: PharmacyVerifyPasswordResetInput) {
        email = input.email
        otpCode = input.otpCode
    }
}

struct PharmacyResetPasswordRequestDTO: Encodable, Equatable {
    let resetToken: String
    let newPassword: String

    init(input: PharmacyResetPasswordInput) {
        resetToken = input.resetToken
        newPassword = input.newPassword
    }
}

struct PharmacyPasswordResetActionResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
}

struct PharmacyPasswordResetVerificationResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
    let data: PharmacyPasswordResetVerificationDataDTO?
}

struct PharmacyPasswordResetVerificationDataDTO: Decodable, Equatable {
    let resetToken: String
    let expiresInSeconds: Int

    func toDomain() -> PharmacyPasswordResetAuthorization {
        PharmacyPasswordResetAuthorization(
            resetToken: resetToken,
            expiresInSeconds: expiresInSeconds
        )
    }
}
