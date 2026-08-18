//
//  PharmacyPasswordResetModels.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

struct PharmacyForgotPasswordInput: Equatable {
    let email: String
}

struct PharmacyVerifyPasswordResetInput: Equatable {
    let email: String
    let otpCode: String
}

struct PharmacyPasswordResetAuthorization: Equatable {
    let resetToken: String
    let expiresInSeconds: Int
}

struct PharmacyResetPasswordInput: Equatable {
    let resetToken: String
    let newPassword: String
}
