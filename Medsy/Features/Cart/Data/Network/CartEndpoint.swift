//
//  CartEndpoint.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Alamofire
import Foundation

enum CartEndpoint: ApiEndpoint {
    case fetch
    case add(AddCartItemRequestDTO)
    case update(itemID: Int64, quantity: Int)
    case remove(itemID: Int64)
    case clear
    case count

    var path: String {
        switch self {
        case .fetch, .clear:
            return "cart"
        case .add:
            return "cart/items"
        case let .update(itemID, _), let .remove(itemID):
            return "cart/items/\(itemID)"
        case .count:
            return "cart/count"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetch, .count:
            return .get
        case .add:
            return .post
        case .update:
            return .patch
        case .remove, .clear:
            return .delete
        }
    }

    var body: Data? {
        switch self {
        case let .add(request):
            return try? JSONEncoder().encode(request)
        case let .update(_, quantity):
            return try? JSONEncoder().encode(quantity)
        case .fetch, .remove, .clear, .count:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
