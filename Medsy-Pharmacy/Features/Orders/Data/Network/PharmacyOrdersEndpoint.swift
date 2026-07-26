//
//  PharmacyOrdersEndpoint.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//


import Alamofire
import Foundation

enum PharmacyOrdersEndpoint: ApiEndpoint {
    case fetchOrders(pharmacyId: Int, page: Int, size: Int, sort: [String]? = nil)

    var path: String {
        switch self {
        case .fetchOrders:
            // OLD:
            // return "orders/pharmacy/\(pharmacyId)"
            return "pharmacies/requests"
        }
    }

    var method: HTTPMethod { .get }

    var queryParameters: Parameters? {
        switch self {
        case .fetchOrders(_, let page, let size, let sort):
            var params: Parameters = ["page": page, "size": size]
            if let sort, !sort.isEmpty {
                params["sort"] = sort
            }
            return params
        }
    }

    var body: Data? { nil }

    var requiresAuthentication: Bool { true }
}
