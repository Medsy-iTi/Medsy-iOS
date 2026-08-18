//
//  AuthEndpoint.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Alamofire
import Foundation

enum AuthEndpoint {
    case login(LoginRequestDTO)
    case register(SignupRequestDTO)
    case verify(VerificationRequestDTO)
    case refresh(RefreshTokenRequestDTO)
    case logout(LogoutRequestDTO)
    case forgotPassword(ForgotPasswordRequestDTO)
    case verifyPasswordReset(VerifyPasswordResetRequestDTO)
    case resetPassword(ResetPasswordRequestDTO)
}

extension AuthEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .login:
            return "auth/login"
        case .register:
            return "auth/register"
        case .verify:
            return "auth/verify"
        case .refresh:
            return "auth/refresh"
        case .logout:
            return "auth/logout"
        case .forgotPassword:
            return "auth/forgot-password"
        case .verifyPasswordReset:
            return "auth/reset-password/verify"
        case .resetPassword:
            return "auth/reset-password"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .verify, .refresh, .logout,
             .forgotPassword, .verifyPasswordReset, .resetPassword:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .login(let request):
            return try? JSONEncoder().encode(request)
        case .register(let request):
            return try? JSONEncoder().encode(request)
        case .verify(let request):
            return try? JSONEncoder().encode(request)
        case .refresh(let request):
            return try? JSONEncoder().encode(request)
        case .logout(let request):
            return try? JSONEncoder().encode(request)
        case .forgotPassword(let request):
            return try? JSONEncoder().encode(request)
        case .verifyPasswordReset(let request):
            return try? JSONEncoder().encode(request)
        case .resetPassword(let request):
            return try? JSONEncoder().encode(request)
        }
    }

    var requiresAuthentication: Bool {
        switch self {
        case .logout:
            return true
        case .login, .register, .verify, .refresh,
             .forgotPassword, .verifyPasswordReset, .resetPassword:
            return false
        }
    }

    var allowsResponseLogging: Bool {
        switch self {
        case .forgotPassword, .verifyPasswordReset, .resetPassword:
            return false
        default:
            return true
        }
    }
}
