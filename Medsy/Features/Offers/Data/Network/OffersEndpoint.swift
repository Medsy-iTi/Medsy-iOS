import Alamofire
import Foundation

enum OffersEndpoint: ApiEndpoint {
    case getResult(requestId: Int)
    case getStream(requestId: Int)
    case selectPharmacy(requestId: Int, body: ConfirmOfferRequestDTO)
    case confirmOffer(requestId: Int, body: ConfirmOfferFulfillmentRequestDTO)
    case getMasterOrders(page: Int, size: Int)
    case getMasterOrder(id: Int)
    case getRequest(requestId: Int)

    var path: String {
        switch self {
        case let .getResult(requestId):
            return "requests/\(requestId)/result"
        case let .getStream(requestId):
            return "requests/\(requestId)/stream"
        case let .selectPharmacy(requestId, _):
            return "requests/\(requestId)/select"
        case let .confirmOffer(requestId, _):
            return "requests/\(requestId)/confirm"
        case .getMasterOrders:
            return "masterorders"
        case let .getMasterOrder(id):
            return "masterorders/\(id)"
        case let .getRequest(requestId):
            return "requests/\(requestId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getResult, .getStream, .getMasterOrders, .getMasterOrder, .getRequest:
            return .get
        case .selectPharmacy, .confirmOffer:
            return .post
        }
    }

    var queryParameters: Parameters? {
        switch self {
        case let .getMasterOrders(page, size):
            return [
                "page": page,
                "size": size,
                "sort": "id,desc"
            ]
        default:
            return nil
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .getStream:
            return ["Accept": "text/event-stream"]
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var body: Data? {
        switch self {
        case .getResult, .getStream, .getMasterOrders, .getMasterOrder, .getRequest:
            return nil
        case let .selectPharmacy(_, body):
            return try? JSONEncoder().encode(body)
        case let .confirmOffer(_, body):
            return try? JSONEncoder().encode(body)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
