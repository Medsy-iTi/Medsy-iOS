//
//  ProfileEndpoint.swift
//  Medsy-Pharmacy
//

import Alamofire
import Foundation

enum ProfileEndpoint: ApiEndpoint {
    // MARK: Fetch
    case fetchPharmacistMe
    case fetchPharmacyMine

    // MARK: Update Personal Profile
    case updateProfile(id: Int, request: UpdatePharmacyProfileRequestDTO)

    // MARK: Pharmacy Actions
    case leavePharmacy(pharmacyId: Int)
    case updatePharmacy(id: Int, request: UpdatePharmacyRequestDTO)

    // MARK: Auth
    case logout(refreshToken: String)

    // MARK: - Path
    var path: String {
        switch self {
        case .fetchPharmacistMe:
            return "pharmacists/me"
        case .fetchPharmacyMine:
            return "pharmacies/mine"
        case let .updateProfile(id, _):
            return "users/\(id)"
        case let .leavePharmacy(pharmacyId):
            return "pharmacists/me/pharmacy/\(pharmacyId)"
        case let .updatePharmacy(id, _):
            return "pharmacies/\(id)"
        case .logout:
            return "auth/logout"
        }
    }

    // MARK: - Method
    var method: HTTPMethod {
        switch self {
        case .fetchPharmacistMe, .fetchPharmacyMine:
            return .get
        case .updateProfile, .updatePharmacy:
            return .patch
        case .leavePharmacy:
            return .delete
        case .logout:
            return .post
        }
    }

    // MARK: - Body
    var body: Data? {
        switch self {
        case .fetchPharmacistMe, .fetchPharmacyMine, .leavePharmacy:
            return nil
        case let .logout(refreshToken):
            return try? JSONEncoder().encode(["refreshToken": refreshToken])
        case let .updateProfile(_, request):
            return try? JSONEncoder().encode(request)
        case let .updatePharmacy(_, request):
            return try? JSONEncoder().encode(request)
        }
    }

    var requiresAuthentication: Bool { true }
}
