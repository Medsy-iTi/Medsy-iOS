// CompletedOrderDetailsEndpoint.swift
// Medsy

import Alamofire
import Foundation

enum CompletedOrderDetailsEndpoint: ApiEndpoint {
    case fetchOrder(id: Int)
    case markReady(orderId: Int)

    var path: String {
        switch self {
        case .fetchOrder(let id):
            return "orders/\(id)"
        case .markReady(let orderId):
            return "pharmacists/orders/\(orderId)/ready"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchOrder: return .get
        case .markReady:  return .patch
        }
    }

    var queryParameters: Parameters? { nil }

    var body: Data? {
        switch self {
        case .fetchOrder:  return nil
        case .markReady:   return Data("{}".utf8)  // Spring Boot needs a non-nil body for PATCH
        }
    }

    var requiresAuthentication: Bool { true }
}
