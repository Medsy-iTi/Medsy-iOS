//
//  PaymentEndpoint.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Alamofire
import Foundation

enum PaymentEndpoint: ApiEndpoint {
    case fetchMasterOrder(id: Int)
    case createIntent(CreatePaymentIntentRequestDTO)

    var path: String {
        switch self {
        case .fetchMasterOrder(let id):
            "masterorders/\(id)"
        case .createIntent:
            "payments/create-intent"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchMasterOrder:
            .get
        case .createIntent:
            .post
        }
    }

    var body: Data? {
        switch self {
        case .fetchMasterOrder:
            nil
        case .createIntent(let request):
            try? JSONEncoder().encode(request)
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
