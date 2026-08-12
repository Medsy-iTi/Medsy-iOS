//
//  PharmacyEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation
import Alamofire

enum PharmacyEndpoint: ApiEndpoint {
    case fetchPharmacy(id: Int)

    var path: String {
        switch self {
        case let .fetchPharmacy(id):
            return "pharmacies/\(id)"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var body: Data? {
        return nil
    }

    var requiresAuthentication: Bool {
        return true
    }
}
