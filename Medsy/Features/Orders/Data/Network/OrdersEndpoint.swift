//
//  OrdersEndpoint.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Alamofire
import Foundation

enum OrdersEndpoint: ApiEndpoint {
    case fetchOrders(page: Int, size: Int, status: String?)
    case fetchOrderDetail(id: Int)

    var path: String {
        switch self {
        case .fetchOrders:
            return "orders"
        case .fetchOrderDetail(let id):
            return "orders/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchOrders(page, size, status):
            var params: Parameters = [
                "page": page,
                "size": size,
                "sort": "date,desc"
            ]
            if let status {
                params["status"] = status
            }
            return params
        case .fetchOrderDetail:
            return nil
        }
    }

    var body: Data? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
