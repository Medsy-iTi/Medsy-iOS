// PharmacyRequestsEndpoint.swift

import Alamofire
import Foundation

enum PharmacyRequestsEndpoint: ApiEndpoint {
    case fetchRequests(page: Int, size: Int)
    case fetchRequestById(requestId: Int)
    case sendOffer(requestId: Int, body: SendOfferRequestDTO)
    case searchProducts(keyword: String, page: Int, size: Int)

    var path: String {
        switch self {
        case .fetchRequests:
            return "pharmacies/requests"
        case .fetchRequestById(let requestId):
            return "pharmacies/requests/\(requestId)"
        case .sendOffer(let requestId, _):
            return "offers/requests/\(requestId)"
        case .searchProducts:
            return "products/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchRequests, .fetchRequestById, .searchProducts:
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
        case let .searchProducts(keyword, page, size):
            return [
                "keyword": keyword,
                "page": page,
                "size": size,
                "lang": "ar"
            ]
        case .fetchRequestById, .sendOffer:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .fetchRequests, .fetchRequestById, .searchProducts:
            return nil
        case let .sendOffer(_, body):
            return try? JSONEncoder().encode(body)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
