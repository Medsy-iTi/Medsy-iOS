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
    case selectOffer(requestId: Int, body: ConfirmOfferRequestDTO)
    case confirmFulfillment(requestId: Int, body: FulfillmentConfirmationRequestDTO)

    var path: String {
        switch self {
        case let .getResult(requestId):
            return "requests/\(requestId)/result"
        case let .selectOffer(requestId, _):
            return "requests/\(requestId)/select"
        case let .confirmFulfillment(requestId, _):
            return "requests/\(requestId)/confirm"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getResult:
            return .get
        case .selectOffer, .confirmFulfillment:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .getResult:
            return nil
        case let .selectOffer(_, body):
            return try? JSONEncoder().encode(body)
        case let .confirmFulfillment(_, body):
            return try? JSONEncoder().encode(body)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
