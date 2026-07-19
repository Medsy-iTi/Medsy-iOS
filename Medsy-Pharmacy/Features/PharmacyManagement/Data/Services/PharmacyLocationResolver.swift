//
//  PharmacyLocationResolver.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import CoreLocation
import Foundation

protocol PharmacyLocationResolving {
    func resolve(latitude: Double, longitude: Double) async throws -> String
}

final class PharmacyLocationResolver: PharmacyLocationResolving {
    private let languageManager: LanguageManager

    init(languageManager: LanguageManager) {
        self.languageManager = languageManager
    }

    func resolve(latitude: Double, longitude: Double) async throws -> String {
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: latitude, longitude: longitude),
            preferredLocale: Locale(identifier: languageManager.languageCode)
        )
        guard let placemark = placemarks.first else {
            throw CLError(.geocodeFoundNoResult)
        }

        let province = placemark.administrativeArea?.trimmingCharacters(in: .whitespacesAndNewlines)
        let city = (placemark.locality ?? placemark.subAdministrativeArea)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let components = [province, city]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .reduce(into: [String]()) { result, component in
                if !result.contains(component) {
                    result.append(component)
                }
            }

        guard !components.isEmpty else {
            throw CLError(.geocodeFoundNoResult)
        }
        return components.joined(separator: ", ")
    }
}
