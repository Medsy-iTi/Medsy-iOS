// CompletedOrderDetailsEndpoint.swift
// Medsy

import Alamofire
import Foundation

enum CompletedOrderDetailsEndpoint: ApiEndpoint {
    case fetchOrder(id: Int)

    var path: String {
        switch self {
        case .fetchOrder(let id):
            return "orders/\(id)"
        }
    }

    var method: HTTPMethod { .get }

    var queryParameters: Parameters? { nil }

    var body: Data? { nil }

    var requiresAuthentication: Bool { true }
}
