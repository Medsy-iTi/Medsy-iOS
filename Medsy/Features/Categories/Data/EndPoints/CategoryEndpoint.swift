//  CategoryEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

import Foundation
import Alamofire

enum CategoryEndpoint: ApiEndpoint {
    case fetch(page: Int, size: Int, lang: String? = nil)

    var path: String {
        return "categories"
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetch(page, size, lang):
            var params: [String: Any] = [
                "page": page,
                "size": size,
                "sort": "name,ASC"
            ]
            if let lang = lang {
                params["lang"] = lang
            }
            return params
        }
    }

    var body: Data? {
        return nil
    }
}
