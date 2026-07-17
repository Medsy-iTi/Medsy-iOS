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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .verify, .refresh, .logout:
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
        }
    }
}
