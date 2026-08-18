//
//  PasswordResetDTO.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

struct ForgotPasswordRequestDTO: Encodable, Equatable {
    let email: String

    init(input: ForgotPasswordInput) {
        email = input.email
    }
}

struct VerifyPasswordResetRequestDTO: Encodable, Equatable {
    let email: String
    let otpCode: String

    init(input: VerifyPasswordResetInput) {
        email = input.email
        otpCode = input.otpCode
    }
}

struct ResetPasswordRequestDTO: Encodable, Equatable {
    let resetToken: String
    let newPassword: String

    init(input: ResetPasswordInput) {
        resetToken = input.resetToken
        newPassword = input.newPassword
    }
}

struct PasswordResetActionResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
}

struct PasswordResetVerificationResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
    let data: PasswordResetVerificationDataDTO?
}

struct PasswordResetVerificationDataDTO: Decodable, Equatable {
    let resetToken: String
    let expiresInSeconds: Int

    func toDomain() -> PasswordResetAuthorization {
        PasswordResetAuthorization(
            resetToken: resetToken,
            expiresInSeconds: expiresInSeconds
        )
    }
}
