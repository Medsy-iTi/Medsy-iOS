//
//  AuthEndpoint.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Alamofire
import Foundation

enum AuthEndpoint {
    case register(SignupRequestDTO)
    case verify(VerificationRequestDTO)
    case refresh(RefreshTokenRequestDTO)
}

extension AuthEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .register:
            return "auth/register"
        case .verify:
            return "auth/verify"
        case .refresh:
            return "auth/refresh"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .verify, .refresh:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .register(let request):
            return try? JSONEncoder().encode(request)
        case .verify(let request):
            return try? JSONEncoder().encode(request)
        case .refresh(let request):
            return try? JSONEncoder().encode(request)
        }
    }
}
