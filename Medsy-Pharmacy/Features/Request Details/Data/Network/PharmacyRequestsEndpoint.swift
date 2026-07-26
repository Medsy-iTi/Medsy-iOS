//
//  PharmacyRequestsEndpoint.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Alamofire
import Foundation

enum PharmacyRequestsEndpoint: ApiEndpoint {
    case fetchRequests(page: Int, size: Int)
    case fetchRequestById(requestId: Int)
    case sendOffer(requestId: Int, body: SendOfferRequestDTO)

    var path: String {
        switch self {
        case .fetchRequests:
            return "pharmacies/requests"
        case .fetchRequestById(let requestId):
            return "pharmacies/requests/\(requestId)"
        case .sendOffer(let requestId, _):
            return "offers/requests/\(requestId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchRequests, .fetchRequestById:
            return .get
        case .sendOffer:
            return .post
        }
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchRequests(page, size):
            return [
                "page": page,
                "size": size
            ]
        case .fetchRequestById, .sendOffer:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .fetchRequests, .fetchRequestById:
            return nil
        case let .sendOffer(_, body):
            return try? JSONEncoder().encode(body)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
