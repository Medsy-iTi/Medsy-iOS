//
//  PharmacyAuthenticationEndpoint.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Alamofire
import Foundation

enum PharmacyAuthenticationEndpoint {
    case register(PharmacyRegistrationRequestDTO)
    case verify(PharmacyVerificationRequestDTO)
}

extension PharmacyAuthenticationEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .register:
            "auth/register"
        case .verify:
            "auth/verify"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case .register(let request):
            try? JSONEncoder().encode(request)
        case .verify(let request):
            try? JSONEncoder().encode(request)
        }
    }
}
