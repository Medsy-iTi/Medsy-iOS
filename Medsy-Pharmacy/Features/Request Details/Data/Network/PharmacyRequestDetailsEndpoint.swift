//  PharmacyRequestDetailsEndpoint.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Alamofire
import Foundation

enum PharmacyRequestDetailsEndpoint: ApiEndpoint {
    case fetchRequestDetails(requestId: Int)

    var path: String {
        switch self {
        case .fetchRequestDetails(let requestId):
            return "orders/\(requestId)"
        }
    }

    var method: HTTPMethod { .get }

    var queryParameters: Parameters? {
        switch self {
        case .fetchRequestDetails:
            return nil
        }
    }

    var body: Data? { nil }

    var requiresAuthentication: Bool { true }
}
