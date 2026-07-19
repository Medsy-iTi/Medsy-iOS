//
//  ProfileEndpoint.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Alamofire
import Foundation

enum ProfileEndpoint: ApiEndpoint {
    case fetchPharmacistMe
    case fetchPharmacyMine

    case logout(refreshToken: String)

    var path: String {
        switch self {
        case .fetchPharmacistMe:
            return "pharmacists/me"
        case .fetchPharmacyMine:
            return "pharmacies/mine"

        case .logout:
            return "auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchPharmacistMe, .fetchPharmacyMine:
            return .get

        case .logout:
            return .post
        }
    }

    var body: Data? {
        switch self {

        case .logout(let refreshToken):
            return try? JSONEncoder().encode(["refreshToken": refreshToken])
        case .fetchPharmacistMe, .fetchPharmacyMine:
            return nil
        }
    }

    var requiresAuthentication: Bool { true }
}
