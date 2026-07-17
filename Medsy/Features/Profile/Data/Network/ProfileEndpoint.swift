//
//  ProfileEndpoint.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Alamofire
import Foundation

enum ProfileEndpoint: ApiEndpoint {
    case fetch
    case update(UpdateCustomerProfileRequestDTO)

    var path: String {
        "customers/me"
    }

    var method: HTTPMethod {
        switch self {
        case .fetch:
            return .get
        case .update:
            return .put
        }
    }

    var body: Data? {
        switch self {
        case .fetch:
            return nil
        case let .update(request):
            return try? JSONEncoder().encode(request)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
