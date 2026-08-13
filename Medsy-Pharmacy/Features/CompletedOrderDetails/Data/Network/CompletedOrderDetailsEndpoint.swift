// CompletedOrderDetailsEndpoint.swift
// Medsy

import Alamofire
import Foundation

enum CompletedOrderDetailsEndpoint: ApiEndpoint {
    case fetchOrder(id: Int)
    case markReady(orderId: Int)
    case markOutForDelivery(orderId: Int)
    case markDelivered(orderId: Int)

    var path: String {
        switch self {
        case .fetchOrder(let id):
            return "orders/\(id)"
        case .markReady(let orderId):
            return "pharmacists/orders/\(orderId)/ready"
        case .markOutForDelivery(let orderId):
            return "pharmacists/orders/\(orderId)/out-for-delivery"
        case .markDelivered(let orderId):
            return "pharmacists/orders/\(orderId)/delivered"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchOrder: return .get
        default:          return .patch
        }
    }

    var queryParameters: Parameters? {
        switch self {
        case .fetchOrder:
            return ["lang": LanguageManager.shared.languageCode]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .fetchOrder: return nil
        default:          return Data("{}".utf8)  // Spring Boot needs a non-nil body for PATCH
        }
    }

    var requiresAuthentication: Bool { true }
}
