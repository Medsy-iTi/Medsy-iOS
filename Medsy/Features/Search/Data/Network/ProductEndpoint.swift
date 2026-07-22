//
//  ProductEndpoint.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation
import Alamofire

enum ProductEndpoint {
	case list(page: Int, size: Int, sort: [ProductSort], lang: String? = nil)
	case search(keyword: String, page: Int, size: Int, sort: [ProductSort], lang: String? = nil)
	case category(id: Int, page: Int, size: Int, sort: [ProductSort], lang: String? = nil)
}

extension ProductEndpoint: ApiEndpoint {

	var method: HTTPMethod { .get }

	var queryParameters: Parameters? { nil }

	var body: Data? { nil }

	var path: String {
		switch self {
			case let .list(page, size, sort, lang):
				var items = [
					URLQueryItem(name: "page", value: "\(page)"),
					URLQueryItem(name: "size", value: "\(size)")
				]

				if let lang = lang {
					items.append(URLQueryItem(name: "lang", value: lang))
				}

				items.append(contentsOf: sort.map { URLQueryItem(name: "sort", value: $0.queryValue) })
				return "products" + Self.queryString(items)

			case let .search(keyword, page, size, sort, lang):
				var items = [
					URLQueryItem(name: "keyword", value: keyword),
					URLQueryItem(name: "page", value: "\(page)"),
					URLQueryItem(name: "size", value: "\(size)")
				]

				if let lang = lang {
					items.append(URLQueryItem(name: "lang", value: lang))
				}

				items.append(contentsOf: sort.map { URLQueryItem(name: "sort", value: $0.queryValue) })
				return "products/search" + Self.queryString(items)

			case let .category(id, page, size, sort, lang):
				var items = [
					URLQueryItem(name: "page", value: "\(page)"),
					URLQueryItem(name: "size", value: "\(size)")
				]

				if let lang = lang {
					items.append(URLQueryItem(name: "lang", value: lang))
				}

				items.append(contentsOf: sort.map { URLQueryItem(name: "sort", value: $0.queryValue) })
				return "products/category/\(id)" + Self.queryString(items)
		}
	}

	private static func queryString(_ items: [URLQueryItem]) -> String {
		var components = URLComponents()
		components.queryItems = items
		guard let query = components.percentEncodedQuery else { return "" }
		return "?\(query)"
	}
}
