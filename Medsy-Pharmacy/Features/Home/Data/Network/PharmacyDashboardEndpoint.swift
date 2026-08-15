//
//  PharmacyDashboardEndpoint.swift
//  Medsy-Pharmacy
//

import Alamofire
import Foundation

enum PharmacyDashboardEndpoint: ApiEndpoint {
    case fetch(period: PharmacyDashboardPeriod)
    case fetchAISummary(period: PharmacyDashboardPeriod)

    var path: String {
        switch self {
        case .fetch:
            "pharmacies/dashboard"
        case .fetchAISummary:
            "ai/dashboard/summary"
        }
    }

    var method: HTTPMethod { .get }

    var queryParameters: Parameters? {
        switch self {
        case .fetch(let period), .fetchAISummary(let period):
            [
                "period": period.rawValue,
                "lang": LanguageManager.shared.languageCode
            ]
        }
    }

    var body: Data? { nil }

    var requiresAuthentication: Bool { true }

    var allowsResponseLogging: Bool { true }
}
