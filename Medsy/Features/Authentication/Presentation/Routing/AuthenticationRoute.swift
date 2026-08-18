//
//  AuthenticationRoute.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

enum AuthenticationRoute: Hashable {
    case login
    case signup
    case verification(email: String)
    case forgotPassword
    case passwordResetOTP
    case resetPassword
}
