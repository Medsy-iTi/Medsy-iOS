//
//  PrescriptionImageEndpoint.swift
//  Medsy-Pharmacy
//

import Alamofire
import Foundation

enum PrescriptionImageEndpoint: ApiEndpoint {
    case fetchImage(path: String)

    var baseURL: String? {
        guard let url = URL(string: PharmacyConfiguration.apiBaseURL),
              let scheme = url.scheme,
              let host = url.host else {
            return PharmacyConfiguration.apiBaseURL
        }
        let port = url.port.map { ":\($0)" } ?? ""
        return "\(scheme)://\(host)\(port)/"
    }

    var path: String {
        switch self {
        case .fetchImage(let path):
            let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
            return cleanPath
        }
    }

    var method: HTTPMethod { .get }

    var body: Data? { nil }

    var requiresAuthentication: Bool { true }

    var allowsResponseLogging: Bool { false }
}
