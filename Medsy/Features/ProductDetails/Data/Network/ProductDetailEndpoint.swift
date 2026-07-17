//
//  ProductDetailEndpoint.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//

import Foundation
import Alamofire

enum ProductDetailEndpoint {
    case detail(id: Int, lang: String?)
}

extension ProductDetailEndpoint: ApiEndpoint {

    var baseURL: String? { Constants.baseURL }

    var method: HTTPMethod { .get }

    var queryParameters: Parameters? { nil }

    var body: Data? { nil }

    var path: String {
        switch self {
        case let .detail(id, lang):
            var items: [URLQueryItem] = []
            if let lang {
                items.append(URLQueryItem(name: "lang", value: lang))
            }
            let query = items.isEmpty ? "" : Self.queryString(items)
            return "products/\(id)\(query)"
        }
    }

    private static func queryString(_ items: [URLQueryItem]) -> String {
        var components = URLComponents()
        components.queryItems = items
        guard let query = components.percentEncodedQuery else { return "" }
        return "?\(query)"
    }
}
