//
//  CompletedOrdersEndpoint.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//

import Alamofire
import Foundation

enum CompletedOrdersEndpoint {
    case getCompletedOrders(pharmacyId: Int, page: Int, size: Int, sort: [String])
}

extension CompletedOrdersEndpoint: ApiEndpoint {
    var path: String {
        switch self {
        case .getCompletedOrders(let pharmacyId, _, _, _):
            return "/api/v1/orders/pharmacy/\(pharmacyId)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: Parameters? {
        switch self {
        case .getCompletedOrders(_, let page, let size, let sort):
            var parameters: Parameters = [
                "page": page,
                "size": size
            ]
				
              if !sort.isEmpty {
                parameters["sort"] = sort
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
