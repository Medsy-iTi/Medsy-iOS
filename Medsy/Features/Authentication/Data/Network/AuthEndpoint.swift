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
}

extension AuthEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .register:
            return "auth/register"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .register(let request):
            return try? JSONEncoder().encode(request)
        }
    }
}
