//
//  ReverseGeocodeError.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//


import CoreLocation

enum ReverseGeocodeError: Error {
    case noResults
}

protocol ReverseGeocodeAddressUseCaseProtocol {

    func execute(coordinate: CLLocationCoordinate2D) async throws -> String
}

final class ReverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol {
    private let geocoder = CLGeocoder()

    func execute(coordinate: CLLocationCoordinate2D) async throws -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        guard let placemark = placemarks.first else {
            throw ReverseGeocodeError.noResults
        }

        return Self.formattedAddress(from: placemark)
    }

    private static func formattedAddress(from placemark: CLPlacemark) -> String {
        [
            placemark.name,
            placemark.thoroughfare,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ]
        .compactMap { $0 }
        .reduce(into: [String]()) { unique, component in
           if unique.last != component {
                unique.append(component)
            }
        }
        .joined(separator: ", ")
    }
}
