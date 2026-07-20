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

    // MARK: Update Profile
    case updateMyProfile(request: UpdatePharmacyProfileRequestDTO)
    case updateUser(id: Int, request: UpdatePharmacyProfileRequestDTO)

    // MARK: Pharmacy Actions
    case leavePharmacy(pharmacyId: Int)
    case updatePharmacy(id: Int, request: UpdatePharmacyRequestDTO)
    case deletePharmacy(id: Int)
    case removePharmacist(pharmacistId: Int, pharmacyId: Int)
    case invitePharmacist(pharmacyId: Int, request: InvitePharmacistRequestDTO)

    // MARK: Auth
    case logout(refreshToken: String)

    // MARK: - Path
    var path: String {
        switch self {
        case .fetchPharmacistMe:
            return "pharmacists/me"
        case .fetchPharmacyMine:
            return "pharmacies/mine"
        case .updateMyProfile:
            return "pharmacists/me"
        case let .updateUser(id, _):
            return "users/\(id)"
        case let .leavePharmacy(pharmacyId):
            return "pharmacists/me/pharmacy/\(pharmacyId)"
        case let .updatePharmacy(id, _), let .deletePharmacy(id):
            return "pharmacies/\(id)"
        case let .removePharmacist(pharmacistId, pharmacyId):
            return "pharmacists/\(pharmacistId)/pharmacy/\(pharmacyId)"
        case let .invitePharmacist(pharmacyId, _):
            return "pharmacy-invitations/pharmacy/\(pharmacyId)"
        case .logout:
            return "auth/logout"
        }
    }

    // MARK: - Method
    var method: HTTPMethod {
        switch self {
        case .fetchPharmacistMe, .fetchPharmacyMine:
            return .get
        case .updateMyProfile, .updateUser, .updatePharmacy:
            return .put
        case .leavePharmacy, .deletePharmacy, .removePharmacist:
            return .delete
        case .invitePharmacist:
            return .post
        case .logout:
            return .post
        }
    }

    // MARK: - Body
    var body: Data? {
        switch self {
        case .fetchPharmacistMe, .fetchPharmacyMine, .leavePharmacy, .deletePharmacy, .removePharmacist:
            return nil
        case let .invitePharmacist(_, request):
            return try? JSONEncoder().encode(request)
        case let .logout(refreshToken):
            return try? JSONEncoder().encode(["refreshToken": refreshToken])
        case let .updateMyProfile(request), let .updateUser(_, request):
            return try? JSONEncoder().encode(request)
        case let .updatePharmacy(_, request):
            return try? JSONEncoder().encode(request)
        }
    }

    var requiresAuthentication: Bool { true }
}
