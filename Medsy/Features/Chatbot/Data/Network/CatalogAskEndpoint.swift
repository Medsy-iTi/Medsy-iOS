
//
//  CatalogAskEndpoint.swift
//  Medsy
//

import Foundation
import Alamofire

enum CatalogAskEndpoint: ApiEndpoint {

    case ask(request: CatalogAskRequestDTO)
    var path: String { "ai/catalog/ask" }
    var method: HTTPMethod { .post }
    var queryParameters: Parameters? { nil }
    var headers: HTTPHeaders? { ["Content-Type": "application/json"] }
    var body: Data? {
        switch self {
        case .ask(let request):
            return try? JSONEncoder().encode(request)
        }
    }

    var multipartFormParts: [MultipartFormPart]? { nil }
    var requiresAuthentication: Bool { true }
    var allowsResponseLogging: Bool { true }
}
