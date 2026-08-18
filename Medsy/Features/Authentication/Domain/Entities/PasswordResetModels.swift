//
//  PasswordResetModels.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

struct ForgotPasswordInput: Equatable {
    let email: String
}

struct VerifyPasswordResetInput: Equatable {
    let email: String
    let otpCode: String
}

struct PasswordResetAuthorization: Equatable {
    let resetToken: String
    let expiresInSeconds: Int
}

struct ResetPasswordInput: Equatable {
    let resetToken: String
    let newPassword: String
}
