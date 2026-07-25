//
//  NetworkConstants.swift
//  Medsy
//
//  Created by Ehab Salah on 30/06/2026.
//

import Foundation

struct Constants {
    private static let secrets: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let values = try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
              ) as? [String: Any] else {
            return [:]
        }
        return values
    }()

    static let baseURL = "http://localhost:8080/api/v1/"
    static let aiKey = secrets["AI_API_KEY"] as? String ?? ""
    static var customerId: String?
}
