//
//  ProfileEndpoint.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Alamofire
import Foundation

enum ProfileEndpoint: ApiEndpoint {
    case fetchProfile
    case updateOrderReceivingStatus(isOpen: Bool)
    case logout

    var path: String {
        switch self {
        case .fetchProfile:
            return "pharmacy/profile"
        case .updateOrderReceivingStatus:
            return "pharmacy/profile/order-receiving-status"
        case .logout:
            return "auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchProfile:
            return .get
        case .updateOrderReceivingStatus:
            return .patch
        case .logout:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .updateOrderReceivingStatus(let isOpen):
            return try? JSONEncoder().encode(["is_accepting_orders": isOpen])
        case .fetchProfile, .logout:
            return nil
        }
    }

    var requiresAuthentication: Bool { true }
}
