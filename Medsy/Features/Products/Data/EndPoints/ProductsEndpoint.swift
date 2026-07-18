//  ProductsEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation
import Alamofire

enum ProductsEndpoint: ApiEndpoint {
    case fetchByCategory(id: Int, page: Int, size: Int)

    var baseURL: String? {
        return "http://localhost:8080"
    }

    var path: String {
        switch self {
        case let .fetchByCategory(id, _, _):
            return "/api/v1/products/category/\(id)"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchByCategory(_, page, size):
            return [
                "page": page,
                "size": size,
                "sort": "price,desc"
            ]
        }
    }

    var body: Data? {
        return nil
    }
}
