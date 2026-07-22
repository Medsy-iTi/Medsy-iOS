//  PharmacyRequestDetailsEndpoint.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Alamofire
import Foundation

enum PharmacyRequestDetailsEndpoint: ApiEndpoint {
    case fetchRequestDetails(requestId: Int)
    case fetchPharmacyRequests(pharmacyId: Int, page: Int, size: Int)

    var path: String {
        switch self {
        case .fetchRequestDetails(let requestId):
            return "orders/\(requestId)"
        case .fetchPharmacyRequests(let pharmacyId, _, _):
            return "orders/pharmacy/\(pharmacyId)"
        }
    }

    var method: HTTPMethod { .get }

    var queryParameters: Parameters? {
        switch self {
        case .fetchRequestDetails:
            return nil
        case .fetchPharmacyRequests(_, let page, let size):
            return ["page": page, "size": size]
        }
    }

    var body: Data? { nil }

    var requiresAuthentication: Bool { true }
}
