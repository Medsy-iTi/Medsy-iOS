//
//  PharmacyConfiguration.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

enum PharmacyConfiguration {
    static let apiBaseURL: String = {
        guard let fileURL = Bundle.main.url(forResource: "PharmacySecrets", withExtension: "plist"),
              let data = try? Data(contentsOf: fileURL),
              let values = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let baseURL = values["API_BASE_URL"] as? String,
              let url = URL(string: baseURL),
              let scheme = url.scheme,
              !scheme.isEmpty,
              url.host != nil else {
            fatalError("Missing or invalid API_BASE_URL in PharmacySecrets.plist")
        }

        return baseURL.hasSuffix("/") ? baseURL : baseURL + "/"
    }()

    static let imageBaseURL: String = {
        guard let url = URL(string: apiBaseURL),
              let scheme = url.scheme,
              let host = url.host else {
            return apiBaseURL
        }
        return "\(scheme)://\(host)/"
    }()

    static let keychainService: String = {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("Missing Pharmacy application bundle identifier")
        }

        return bundleIdentifier + ".authentication"
    }()

    static let aiKey: String = {
        guard let fileURL = Bundle.main.url(forResource: "PharmacySecrets", withExtension: "plist"),
              let data = try? Data(contentsOf: fileURL),
              let values = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let key = values["GEMINI_API_KEY"] as? String else {
            fatalError("Missing GEMINI_API_KEY in PharmacySecrets.plist")
        }
        return key
    }()
}

