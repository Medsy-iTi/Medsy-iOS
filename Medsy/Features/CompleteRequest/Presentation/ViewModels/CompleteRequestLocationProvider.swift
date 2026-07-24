//
//  CompleteRequestLocationProvider.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import CoreLocation

enum CompleteRequestLocationProviderError: Error {
    case permissionDenied
    case locationUnavailable
}

@MainActor
protocol CompleteRequestLocationProviderProtocol {
    func currentCoordinate() async throws -> CLLocationCoordinate2D
}

@MainActor
final class CompleteRequestLocationProvider: NSObject, CompleteRequestLocationProviderProtocol {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func currentCoordinate() async throws -> CLLocationCoordinate2D {
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
                finish(throwing: CompleteRequestLocationProviderError.permissionDenied)
            @unknown default:
                finish(throwing: CompleteRequestLocationProviderError.locationUnavailable)
            }
        }
    }

    private func finish(with coordinate: CLLocationCoordinate2D) {
        continuation?.resume(returning: coordinate)
        continuation = nil
    }

    private func finish(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension CompleteRequestLocationProvider: @preconcurrency CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard continuation != nil else { return }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            finish(throwing: CompleteRequestLocationProviderError.permissionDenied)
        case .notDetermined:
            break
        @unknown default:
            finish(throwing: CompleteRequestLocationProviderError.locationUnavailable)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            finish(throwing: CompleteRequestLocationProviderError.locationUnavailable)
            return
        }
        finish(with: coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(throwing: error)
    }
}
