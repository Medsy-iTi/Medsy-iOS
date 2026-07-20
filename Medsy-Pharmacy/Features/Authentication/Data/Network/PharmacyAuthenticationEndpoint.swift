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
    case refresh(PharmacyRefreshTokenRequestDTO)
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
        case .refresh:
            "auth/refresh"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case .login(let request):
            try? JSONEncoder().encode(request)
        case .register(let request):
            try? JSONEncoder().encode(request)
        case .verify(let request):
            try? JSONEncoder().encode(request)
        case .refresh(let request):
            try? JSONEncoder().encode(request)
        }
    }
}
