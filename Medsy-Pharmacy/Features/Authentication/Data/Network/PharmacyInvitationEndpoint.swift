import Alamofire
import Foundation

enum PharmacyInvitationEndpoint: ApiEndpoint {
    case pending
    case accept(id: Int)
    case decline(id: Int)

    var path: String {
        switch self {
        case .pending:
            "pharmacy-invitations/me"
        case let .accept(id):
            "pharmacy-invitations/\(id)/accept"
        case let .decline(id):
            "pharmacy-invitations/\(id)/decline"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .pending:
            .get
        case .accept, .decline:
            .patch
        }
    }

    var body: Data? { nil }
    var requiresAuthentication: Bool { true }
}
