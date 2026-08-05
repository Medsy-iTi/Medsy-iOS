//
//  PharmacyDashboardEndpoint.swift
//  Medsy-Pharmacy
//

import Alamofire
import Foundation

enum PharmacyDashboardEndpoint: ApiEndpoint {
    case fetch(period: PharmacyDashboardPeriod)

    var path: String { "pharmacies/dashboard" }

    var method: HTTPMethod { .get }

    var queryParameters: Parameters? {
        switch self {
        case .fetch(let period):
            ["period": period.rawValue]
        }
    }

    var body: Data? { nil }

    var requiresAuthentication: Bool { true }

    var allowsResponseLogging: Bool { false }
}
