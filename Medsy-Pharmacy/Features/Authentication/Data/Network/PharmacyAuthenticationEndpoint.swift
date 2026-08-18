//
//  PharmacyAuthenticationEndpoint.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Alamofire
import Foundation

enum PharmacyAuthenticationEndpoint {
    case login(PharmacyLoginRequestDTO)
    case register(PharmacyRegistrationRequestDTO)
    case verify(PharmacyVerificationRequestDTO)
    case currentPharmacist
    case createPharmacy(PharmacyMultipartFormData)
    case refresh(PharmacyRefreshTokenRequestDTO)
    case forgotPassword(PharmacyForgotPasswordRequestDTO)
    case verifyPasswordReset(PharmacyVerifyPasswordResetRequestDTO)
    case resetPassword(PharmacyResetPasswordRequestDTO)
}

extension PharmacyAuthenticationEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .login:
            "auth/login"
        case .register:
            "auth/register"
        case .verify:
            "auth/verify"
        case .currentPharmacist:
            "pharmacists/me"
        case .createPharmacy:
            "pharmacies"
        case .refresh:
            "auth/refresh"
        case .forgotPassword:
            "auth/forgot-password"
        case .verifyPasswordReset:
            "auth/reset-password/verify"
        case .resetPassword:
            "auth/reset-password"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .currentPharmacist:
            .get
        default:
            .post
        }
    }

    var body: Data? {
        switch self {
        case .login(let request):
            try? JSONEncoder().encode(request)
        case .register(let request):
            try? JSONEncoder().encode(request)
        case .verify(let request):
            try? JSONEncoder().encode(request)
        case .currentPharmacist:
            nil
        case let .createPharmacy(form):
            form.body
        case .refresh(let request):
            try? JSONEncoder().encode(request)
        case .forgotPassword(let request):
            try? JSONEncoder().encode(request)
        case .verifyPasswordReset(let request):
            try? JSONEncoder().encode(request)
        case .resetPassword(let request):
            try? JSONEncoder().encode(request)
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case let .createPharmacy(form):
            return ["Content-Type": "multipart/form-data; boundary=\(form.boundary)"]
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var requiresAuthentication: Bool {
        switch self {
        case .currentPharmacist, .createPharmacy:
            true
        default:
            false
        }
    }

    var allowsResponseLogging: Bool {
        switch self {
        case .forgotPassword, .verifyPasswordReset, .resetPassword:
            false
        default:
            true
        }
    }
}
