//
//  SearchAddressUseCase.swift
//  Medsy
//
//  Created by Shahudaa on 20/07/2026.
//


import Foundation
import MapKit

protocol SearchAddressUseCaseProtocol {
	func execute(query: String, region: MKCoordinateRegion) async throws -> [MKMapItem]
}

final class SearchAddressUseCase: SearchAddressUseCaseProtocol {

	func execute(query: String, region: MKCoordinateRegion) async throws -> [MKMapItem] {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = query
		request.region = region

		let search = MKLocalSearch(request: request)

		return try await withCheckedThrowingContinuation { continuation in
			search.start { response, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else if let response = response {
					continuation.resume(returning: response.mapItems)
				} else {
					continuation.resume(throwing: NSError(domain: "AddressSearchError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown search error"]))
				}
			}
		}
	}
}
