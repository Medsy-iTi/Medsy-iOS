//
//  Pharmacy.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation
import CoreLocation

struct Pharmacy: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String
    let phoneNumber: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
