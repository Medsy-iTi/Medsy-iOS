//
//  AddressPickerViewModel.swift
//  Medsy
//
//  Created by Shahudaa on 20/07/2026.
//

import Observation
import MapKit
import CoreLocation
import SwiftUI

@Observable
@MainActor
final class AddressPickerViewModel {

	var searchText: String = ""
	var addressText: String
	var cameraPosition: MapCameraPosition
	var searchResults: [MKMapItem] = []
	var isSearching = false
	var isResolvingAddress = false

	private let searchDebounceNanoseconds: UInt64 = 350_000_000
	private var searchTask: Task<Void, Never>?


	private(set) var pickedCoordinate: CLLocationCoordinate2D?
	var latitude: Double? { pickedCoordinate?.latitude }
	var longitude: Double? { pickedCoordinate?.longitude }

	var hasPickedLocation: Bool { pickedCoordinate != nil }

	private var region: MKCoordinateRegion

	private let searchAddressUseCase: SearchAddressUseCaseProtocol
	private let reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol
	private let onConfirm: (_ address: String, _ latitude: Double, _ longitude: Double) -> Void
	let onCancel: () -> Void
	private let locationManager = CLLocationManager()
	private var reverseGeocodeTask: Task<Void, Never>?
	private var initialLocationTask: Task<Void, Never>?

	init(
		initialAddress: String = "",
		initialCoordinate: CLLocationCoordinate2D? = nil,
		searchAddressUseCase: SearchAddressUseCaseProtocol,
		reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol,
		onConfirm: @escaping (_ address: String, _ latitude: Double, _ longitude: Double) -> Void,
		onCancel: @escaping () -> Void
	) {
		self.addressText = initialAddress
		self.searchAddressUseCase = searchAddressUseCase
		self.reverseGeocodeAddressUseCase = reverseGeocodeAddressUseCase
		self.onConfirm = onConfirm
		self.onCancel = onCancel

		let coordinate = initialCoordinate ?? CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357) // Cairo fallback
		let initialRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
		self.region = initialRegion
		self.cameraPosition = .region(initialRegion)
		self.pickedCoordinate = initialCoordinate
	}

	var annotatedItems: [AnnotatedMapItem] {
		searchResults.map { AnnotatedMapItem(mapItem: $0) }
	}



	func scheduleSearch() {
		searchTask?.cancel()

		let query = searchText.trimmingCharacters(in: .whitespaces)
		guard !query.isEmpty else {
			searchResults = []
			isSearching = false
			return
		}

		searchTask = Task { [weak self] in
			try? await Task.sleep(nanoseconds: self?.searchDebounceNanoseconds ?? 350_000_000)
			guard let self, !Task.isCancelled else { return }
			await self.performSearch()
		}
	}

	func performSearch() async {
		let query = searchText.trimmingCharacters(in: .whitespaces)
		guard !query.isEmpty else {
			searchResults = []
			return
		}

		isSearching = true
		defer { isSearching = false }

		do {
			let results = try await searchAddressUseCase.execute(query: query, region: region)
			guard !Task.isCancelled else { return }
			searchResults = results

			if let first = results.first {
				moveCamera(to: first.placemark.coordinate)
			}
		} catch {
			guard !Task.isCancelled else { return }
			print("Search failed: \(error)")
		}
	}


	func selectSearchResult(_ item: MKMapItem) {
		searchTask?.cancel()
		addressText = item.name ?? item.placemark.title ?? addressText
		pickedCoordinate = item.placemark.coordinate
		moveCamera(to: item.placemark.coordinate)
		searchResults = []
		searchText = ""
		logPickedLocation()
	}

	func resolveInitialLocationIfNeeded() {
		guard pickedCoordinate == nil else { return }
		let query = addressText.trimmingCharacters(in: .whitespaces)
		guard !query.isEmpty else { return }

		initialLocationTask?.cancel()
		initialLocationTask = Task { [weak self] in
			guard let self else { return }
			self.isResolvingAddress = true
			defer { self.isResolvingAddress = false }

			do {
				let results = try await self.searchAddressUseCase.execute(query: query, region: self.region)
				guard !Task.isCancelled, let first = results.first else { return }
				self.pickedCoordinate = first.placemark.coordinate
				self.moveCamera(to: first.placemark.coordinate)
				self.logPickedLocation()
			} catch {
				guard !Task.isCancelled else { return }
				print("Failed to resolve last saved address: \(error)")
			}
		}
	}

	func selectPin(at coordinate: CLLocationCoordinate2D) {
		pickedCoordinate = coordinate
		reverseGeocodeTask?.cancel()

		reverseGeocodeTask = Task { [weak self] in
			guard let self else { return }
			self.isResolvingAddress = true
			defer { self.isResolvingAddress = false }

			do {
				let resolvedAddress = try await self.reverseGeocodeAddressUseCase.execute(coordinate: coordinate)
				guard !Task.isCancelled else { return }
				self.addressText = resolvedAddress
			} catch {
				guard !Task.isCancelled else { return }
				print("Reverse geocoding failed: \(error)")
			}
			self.logPickedLocation()
		}
	}

	private func logPickedLocation() {
		guard let pickedCoordinate else { return }
		print("📍 lat: \(pickedCoordinate.latitude), lon: \(pickedCoordinate.longitude) — address: \(addressText)")
	}

	func updateRegion(_ newRegion: MKCoordinateRegion) {
		region = newRegion
	}

	func zoomIn() {
		applyZoom(factor: 0.5)
	}

	func zoomOut() {
		applyZoom(factor: 2)
	}

	private func applyZoom(factor: Double) {
		let minDelta = 0.002
		let maxDelta = 60.0
		region.span = MKCoordinateSpan(
			latitudeDelta: min(max(region.span.latitudeDelta * factor, minDelta), maxDelta),
			longitudeDelta: min(max(region.span.longitudeDelta * factor, minDelta), maxDelta)
		)
		withAnimation(.easeInOut(duration: 0.2)) {
			cameraPosition = .region(region)
		}
	}

	private func moveCamera(to coordinate: CLLocationCoordinate2D) {
		region.center = coordinate
		withAnimation(.easeInOut(duration: 0.25)) {
			cameraPosition = .region(region)
		}
	}



	func confirmSelection() {
		guard let pickedCoordinate else { return }
		onConfirm(addressText, pickedCoordinate.latitude, pickedCoordinate.longitude)
	}

	func requestLocationPermission() {
		locationManager.requestWhenInUseAuthorization()
	}
}
