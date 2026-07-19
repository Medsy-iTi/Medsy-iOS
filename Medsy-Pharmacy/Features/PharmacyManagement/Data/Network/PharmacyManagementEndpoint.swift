//
//  PharmacyManagementEndpoint.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Alamofire
import Foundation

enum PharmacyManagementEndpoint {
    case mine
    case create(PharmacyMultipartBody)
    case update(Int, UpdatePharmacyRequestDTO)
    case delete(Int)
}

extension PharmacyManagementEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .mine:
            "pharmacies/mine"
        case .create:
            "pharmacies"
        case let .update(id, _), let .delete(id):
            "pharmacies/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .mine:
            .get
        case .create:
            .post
        case .update:
            .put
        case .delete:
            .delete
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case let .create(multipart):
            ["Content-Type": "multipart/form-data; boundary=\(multipart.boundary)"]
        default:
            ["Content-Type": "application/json"]
        }
    }

    var body: Data? {
        switch self {
        case .mine, .delete:
            nil
        case let .create(multipart):
            multipart.data
        case let .update(_, request):
            try? JSONEncoder().encode(request)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
