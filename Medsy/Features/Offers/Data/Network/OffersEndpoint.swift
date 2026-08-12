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
    case selectPharmacy(requestId: Int, body: ConfirmOfferRequestDTO)
    case confirmOffer(requestId: Int)

    var path: String {
        switch self {
        case let .getResult(requestId):
            return "requests/\(requestId)/result"
        case let .getStream(requestId):
            return "requests/\(requestId)/stream"
        case let .selectPharmacy(requestId, _):
            return "requests/\(requestId)/select"
        case let .confirmOffer(requestId):
            return "requests/\(requestId)/confirm"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getResult, .getStream:
            return .get
        case .selectPharmacy, .confirmOffer:
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
        case .getResult, .getStream, .confirmOffer:
            return nil
        case let .selectPharmacy(_, body):
            return try? JSONEncoder().encode(body)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
