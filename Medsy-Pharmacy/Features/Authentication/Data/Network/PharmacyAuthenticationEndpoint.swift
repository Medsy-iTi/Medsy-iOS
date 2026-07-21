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
}
