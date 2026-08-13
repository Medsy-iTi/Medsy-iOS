//
//  OrderMapServices.swift
//  Medsy
//
//  Created by Codex on 12/08/2026.
//

import CoreLocation
import MapKit

@MainActor
final class OrderCurrentLocationProvider: NSObject, OrderCurrentLocationProviding {
    private let manager: CLLocationManager
    private var continuation: CheckedContinuation<OrderCoordinatePresentation, Error>?

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func currentLocation() async throws -> OrderCoordinatePresentation {
        if let continuation {
            continuation.resume(throwing: CancellationError())
            self.continuation = nil
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                finish(throwing: OrderLocationError.permissionDenied)
            @unknown default:
                finish(throwing: OrderLocationError.locationUnavailable)
            }
        }
    }

    private func finish(with location: CLLocation) {
        continuation?.resume(returning: OrderCoordinatePresentation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ))
        continuation = nil
    }

    private func finish(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension OrderCurrentLocationProvider: @preconcurrency CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard continuation != nil else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            finish(throwing: OrderLocationError.permissionDenied)
        case .notDetermined:
            break
        @unknown default:
            finish(throwing: OrderLocationError.locationUnavailable)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finish(throwing: OrderLocationError.locationUnavailable)
            return
        }
        finish(with: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(throwing: OrderLocationError.locationUnavailable)
    }
}

@MainActor
final class OrderRouteProvider: OrderRouteProviding {
    func route(
        from source: OrderCoordinatePresentation,
        to destination: OrderCoordinatePresentation
    ) async throws -> [OrderCoordinatePresentation] {
        let request = MKDirections.Request()
        request.source = mapItem(for: source)
        request.destination = mapItem(for: destination)
        request.transportType = .automobile

        let response = try await MKDirections(request: request).calculate()
        guard let polyline = response.routes.first?.polyline else {
            throw OrderLocationError.routeUnavailable
        }

        var coordinates = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: polyline.pointCount
        )
        polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: polyline.pointCount))
        return coordinates.map {
            OrderCoordinatePresentation(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    private func mapItem(for coordinate: OrderCoordinatePresentation) -> MKMapItem {
        MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )))
    }
}

@MainActor
final class OrderDirectionsOpener: OrderDirectionsOpening {
    func openDirections(to destination: OrderCoordinatePresentation, name: String) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: destination.latitude,
            longitude: destination.longitude
        )))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
