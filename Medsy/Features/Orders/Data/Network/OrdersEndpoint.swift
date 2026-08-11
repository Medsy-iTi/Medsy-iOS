import Alamofire
import Foundation

enum OrdersEndpoint: ApiEndpoint {
    case fetchOrders(page: Int, size: Int)
    case fetchOrderDetail(id: Int)

    var path: String {
        switch self {
        case .fetchOrders:
            return "masterorders"
        case .fetchOrderDetail(let id):
            return "masterorders/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchOrders(page, size):
            return [
                "page": page,
                "size": size
            ]
        case .fetchOrderDetail:
            return nil
        }
    }

    var body: Data? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
