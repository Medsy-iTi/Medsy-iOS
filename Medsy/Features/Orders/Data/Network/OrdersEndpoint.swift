import Alamofire
import Foundation

enum OrdersEndpoint: ApiEndpoint {
    case fetchOrders(page: Int, size: Int, language: String)
    case fetchOrderDetail(id: Int, language: String)

    var path: String {
        switch self {
        case .fetchOrders:
            return "masterorders"
        case .fetchOrderDetail(let id, _):
            return "masterorders/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchOrders(page, size, language):
            return [
                "page": page,
                "size": size,
                "lang": language
            ]
        case .fetchOrderDetail(_, let language):
            return ["lang": language]
        }
    }

    var body: Data? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
