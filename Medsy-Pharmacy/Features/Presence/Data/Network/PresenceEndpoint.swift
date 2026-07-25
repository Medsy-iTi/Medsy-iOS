//  PresenceEndpoint.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Alamofire
import Foundation

enum PresenceEndpoint: ApiEndpoint {
    case goOnDuty
    case goOffDuty
    case heartbeat

    var path: String {
        switch self {
        case .goOnDuty:
            return "pharmacists/me/presence/on-duty"
        case .goOffDuty:
            return "pharmacists/me/presence/off-duty"
        case .heartbeat:
            return "pharmacists/me/presence/heartbeat"
        }
    }

    var method: HTTPMethod { .post }
    var queryParameters: Parameters? { nil }
    var body: Data? { nil }
    var requiresAuthentication: Bool { true }
}
