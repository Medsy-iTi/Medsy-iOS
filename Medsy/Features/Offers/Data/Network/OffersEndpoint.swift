//
//  OffersEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Alamofire
import Foundation

enum OffersEndpoint: ApiEndpoint {
    case getResult(requestId: Int)
    case getStream(requestId: Int)
    case confirmOffer(requestId: Int, body: ConfirmOfferRequestDTO)

    var path: String {
        switch self {
        case let .getResult(requestId):
            return "requests/\(requestId)/result"
        case let .getStream(requestId):
            return "requests/\(requestId)/stream"
        case let .confirmOffer(requestId, _):
            return "requests/\(requestId)/confirm"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getResult, .getStream:
            return .get
        case .confirmOffer:
            return .post
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .getStream:
            return ["Accept": "text/event-stream"]
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var body: Data? {
        switch self {
        case .getResult, .getStream:
            return nil
        case let .confirmOffer(_, body):
            return try? JSONEncoder().encode(body)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
