//
//  CompletedOrdersEndpoint.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//

import Alamofire
import Foundation

enum CompletedOrdersEndpoint {
    case getCompletedOrders(pharmacyId: Int, status: String?, page: Int, size: Int, sort: [String])
}

extension CompletedOrdersEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .getCompletedOrders(let pharmacyId, _, _, _, _):
            return "orders/pharmacy/\(pharmacyId)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: Parameters? {
        switch self {
        case .getCompletedOrders(_, let status, let page, let size, let sort):
            var parameters: Parameters = [
                "page": page,
                "size": size,
                "lang": LanguageManager.shared.languageCode
            ]

            if let firstSort = sort.first {
                parameters["sort"] = firstSort
            }

            if let status = status {
                parameters["status"] = status
            }

            return parameters
        }
    }

    var body: Data? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
