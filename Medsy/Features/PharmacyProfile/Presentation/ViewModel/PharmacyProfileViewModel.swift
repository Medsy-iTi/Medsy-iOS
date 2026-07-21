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

    private let fetchPharmacyProfileUseCase: FetchPharmacyProfileUseCaseProtocol?

    init(fetchPharmacyProfileUseCase: FetchPharmacyProfileUseCaseProtocol? = nil) {
        self.fetchPharmacyProfileUseCase = fetchPharmacyProfileUseCase
        self.loadPharmacy()
    }

    func loadPharmacy(id: Int = 1) {
        state = .loading
        Task {
            do {
                if let fetchPharmacyProfileUseCase {
                    let pharmacy = try await fetchPharmacyProfileUseCase.execute(id: id)
                    state = .loaded(pharmacy)
                } else {
                    let dto = PharmacyDataDTO(
                        id: id,
                        name: "El-Eman Pharmacy",
                        latitude: 30.0444,
                        longitude: 31.2357,
                        address: "123 Al Tahrir Street, Downtown, Cairo",
                        phoneNumber: "+201234567890"
                    )
                    let pharmacy = PharmacyMapper.map(dto)
                    state = .loaded(pharmacy)
                }
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func callPharmacy(phoneNumber: String) {
        let cleaned = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
