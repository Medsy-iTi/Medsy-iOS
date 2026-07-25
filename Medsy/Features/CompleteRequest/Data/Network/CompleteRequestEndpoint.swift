//
//  CompleteRequestEndpoint.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Alamofire
import Foundation

enum CompleteRequestEndpoint: ApiEndpoint {
    case submit(CompleteRequestDTO)

    var path: String {
        "requests"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case let .submit(request):
            try? JSONEncoder().encode(request)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
