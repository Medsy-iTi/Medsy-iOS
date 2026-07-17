//  PharmacyAuthEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Alamofire
import Foundation

enum PharmacyAuthEndpoint {
    case login(LoginRequestDTO)
}

extension PharmacyAuthEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .login:
            return "auth/login"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .login(let request):
            return try? JSONEncoder().encode(request)
        }
    }
}
