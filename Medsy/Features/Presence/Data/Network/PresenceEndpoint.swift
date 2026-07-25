//  PresenceEndpoint.swift
//  Medsy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Alamofire
import Foundation

enum PresenceEndpoint: ApiEndpoint {
    case heartbeat

    var path: String {
        "pharmacists/me/presence/heartbeat"
    }

    var method: HTTPMethod { .post }
    var queryParameters: Parameters? { nil }
    var body: Data? { nil }
    var requiresAuthentication: Bool { true }
}
