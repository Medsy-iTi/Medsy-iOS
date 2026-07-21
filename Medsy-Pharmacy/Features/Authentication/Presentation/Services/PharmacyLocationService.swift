import CoreLocation
import Foundation

@MainActor
protocol PharmacyLocationProviding: AnyObject {
    func currentLocation() async throws -> PharmacyLocation
    func location(latitude: Double, longitude: Double) async throws -> PharmacyLocation
}

enum PharmacyLocationError: LocalizedError {
    case permissionDenied
    case unavailable
    case addressUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "pharmacy.setup.location.permission_denied".localized
        case .unavailable:
            "pharmacy.setup.location.unavailable".localized
        case .addressUnavailable:
            "pharmacy.setup.location.address_unavailable".localized
        }
    }
}

@MainActor
final class PharmacyLocationService: NSObject, PharmacyLocationProviding, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private let geocoder: CLGeocoder
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        manager = CLLocationManager()
        geocoder = CLGeocoder()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func currentLocation() async throws -> PharmacyLocation {
        let authorization = manager.authorizationStatus
        guard authorization != .denied, authorization != .restricted else {
            throw PharmacyLocationError.permissionDenied
        }

        let coordinate = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation?.resume(throwing: CancellationError())
                self.continuation = continuation

                if authorization == .notDetermined {
                    manager.requestWhenInUseAuthorization()
                } else {
                    manager.requestLocation()
                }
            }
        } onCancel: {
            Task { @MainActor in
                self.finish(with: .failure(CancellationError()))
            }
        }

        return try await reverseGeocode(coordinate)
    }

    func location(latitude: Double, longitude: Double) async throws -> PharmacyLocation {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            throw PharmacySetupValidationError.invalidCoordinates
        }
        return try await reverseGeocode(
            CLLocation(latitude: latitude, longitude: longitude)
        )
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if continuation != nil {
                manager.requestLocation()
            }
        case .denied, .restricted:
            finish(with: .failure(PharmacyLocationError.permissionDenied))
        case .notDetermined:
            break
        @unknown default:
            finish(with: .failure(PharmacyLocationError.unavailable))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finish(with: .failure(PharmacyLocationError.unavailable))
            return
        }
        finish(with: .success(location))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let locationError = error as? CLError, locationError.code == .denied {
            finish(with: .failure(PharmacyLocationError.permissionDenied))
        } else {
            finish(with: .failure(PharmacyLocationError.unavailable))
        }
    }

    private func finish(with result: Result<CLLocation, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }

    private func reverseGeocode(_ location: CLLocation) async throws -> PharmacyLocation {
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw PharmacyLocationError.addressUnavailable
        }

        let city = placemark.locality
            ?? placemark.subAdministrativeArea
            ?? placemark.name
            ?? ""
        let province = placemark.administrativeArea
            ?? placemark.country
            ?? ""

        guard !city.isEmpty, !province.isEmpty else {
            throw PharmacyLocationError.addressUnavailable
        }

        return PharmacyLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            city: city,
            province: province
        )
    }
}
