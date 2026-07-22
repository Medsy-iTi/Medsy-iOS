//  CategoryEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

import Foundation
import Alamofire

enum CategoryEndpoint: ApiEndpoint {
    case fetch(page: Int, size: Int)

    var path: String {
        return "categories"
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetch(page, size):
            return [
                "page": page,
                "size": size,
                "sort": "name,ASC"
            ]
        }
    }

    var body: Data? {
        return nil
    }
}
