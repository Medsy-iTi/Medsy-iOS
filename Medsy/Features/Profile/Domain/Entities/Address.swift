//
//  Address.swift
//  Medsy
//
//  Created by Shahudaa on 20/07/2026.
//

import MapKit

import CoreLocation

struct Address: Equatable, Identifiable {
	let id: String
	let fullAddress: String
	let coordinate: CLLocationCoordinate2D
	let city: String?
	let country: String?

	static func == (lhs: Address, rhs: Address) -> Bool {
		lhs.id == rhs.id &&
		lhs.fullAddress == rhs.fullAddress &&
		lhs.coordinate.latitude == rhs.coordinate.latitude &&
		lhs.coordinate.longitude == rhs.coordinate.longitude
	}
}
