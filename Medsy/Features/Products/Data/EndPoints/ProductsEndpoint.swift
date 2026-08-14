//  ProductsEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation
import Alamofire

enum ProductsEndpoint: ApiEndpoint {
    case fetchByCategory(id: Int, page: Int, size: Int, language: String)

    var path: String {
        switch self {
        case let .fetchByCategory(id, _, _, _):
            return "products/category/\(id)"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchByCategory(_, page, size, language):
            return [
                "page": page,
                "size": size,
                "sort": "price,desc",
                "lang": language
            ]
        }
    }

    var body: Data? {
        return nil
    }
}
