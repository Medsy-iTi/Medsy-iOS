import Alamofire
import Foundation

enum OrdersEndpoint: ApiEndpoint {
    case fetchOrders(page: Int, size: Int, language: String, status: String? = nil)
    case fetchOrderDetail(id: Int, language: String)
    case fetchRequestDetail(id: Int, language: String)

    var path: String {
        switch self {
        case .fetchOrders:
            return "masterorders"
        case .fetchOrderDetail(let id, _):
            return "masterorders/\(id)"
        case .fetchRequestDetail(let id, _):
            return "requests/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchOrders(page, size, language, status):
            var parameters: Parameters = [
                "page": page,
                "size": size,
                "lang": language
            ]
            if let status {
                parameters["status"] = status
            }
            return parameters
        case .fetchOrderDetail(_, let language):
            return ["lang": language]
        case .fetchRequestDetail(_, let language):
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
