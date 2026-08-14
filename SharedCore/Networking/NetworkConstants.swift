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

    static let baseURL = secrets["API_BASE_URL"] as? String ?? ""
    static let aiKey = secrets["AI_API_KEY"] as? String ?? ""
    static let stripePublishableKey = secrets["STRIPE_PUBLISHABLE_KEY"] as? String
        ?? "pk_test_51TyJNlPlZoIXi2nue8U6HypO5sDU07KkOZ0BssAehzPu2u2QSXonBTleRCLJ2iQF5USOg1qWaud5aMzdG9V1Vdt1008zcm8jsp"
    static var customerId: String?
}
