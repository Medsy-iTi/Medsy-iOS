//
//  PharmacyProfileViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation
import Observation
import UIKit
import MapKit

@MainActor
@Observable
final class PharmacyProfileViewModel {
    private(set) var state: PharmacyProfileState = .idle
    private(set) var orderNumber: String = "#1024"

    private let pharmacyId: Int
    private let fetchPharmacyProfileUseCase: FetchPharmacyProfileUseCaseProtocol

    nonisolated init(
        pharmacyId: Int = 2,
        fetchPharmacyProfileUseCase: FetchPharmacyProfileUseCaseProtocol = DIContainer.shared.resolve(FetchPharmacyProfileUseCaseProtocol.self)
    ) {
        self.pharmacyId = pharmacyId
        self.fetchPharmacyProfileUseCase = fetchPharmacyProfileUseCase
        Task { @MainActor in
            self.loadPharmacy(id: pharmacyId)
        }
    }

    func loadPharmacy(id: Int? = nil) {
        let targetId = id ?? pharmacyId
        state = .loading
        Task {
            do {
                let pharmacy = try await fetchPharmacyProfileUseCase.execute(id: targetId)
                state = .loaded(pharmacy)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func callPharmacy(phoneNumber: String) {
        PharmacyCallHandler.call(phoneNumber: phoneNumber)
    }

    func openDirections(latitude: Double, longitude: Double, name: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    func sharePharmacy(name: String, address: String) {
        let text = "\(name)\n\(address)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
