import Alamofire
import Foundation

enum OrdersEndpoint: ApiEndpoint {
    case fetchOrders(page: Int, size: Int, status: String?, dateFrom: String?, dateTo: String?)
    case fetchOrderDetail(id: Int)

    var path: String {
        switch self {
        case .fetchOrders:
            return "orders"
        case .fetchOrderDetail(let id):
            return "orders/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: Parameters? {
        switch self {
        case let .fetchOrders(page, size, status, dateFrom, dateTo):
            var params: Parameters = [
                "page": page,
                "size": size,
                "sort": "date,desc"
            ]
            if let status { params["status"] = status }
            if let dateFrom { params["dateFrom"] = dateFrom }
            if let dateTo { params["dateTo"] = dateTo }
            return params
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
