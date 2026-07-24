//
//  CompleteRequestLocationPickerViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import CoreLocation
import MapKit
import Observation
import SwiftUI

@MainActor
@Observable
final class CompleteRequestLocationPickerViewModel: CompleteRequestLocationPickerViewModelProtocol {
    var searchText = ""
    private(set) var addressText: String
    private(set) var searchResults: [MKMapItem] = []
    var cameraPosition: MapCameraPosition
    private(set) var selectedCoordinate: CLLocationCoordinate2D?
    private(set) var isSearching = false
    private(set) var isResolvingAddress = false
    private(set) var locationErrorMessage: String?

    private let searchAddressUseCase: SearchAddressUseCaseProtocol
    private let reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol
    private let locationProvider: CompleteRequestLocationProviderProtocol
    private var region: MKCoordinateRegion
    private var searchTask: Task<Void, Never>?
    private var geocodeTask: Task<Void, Never>?

    init(
        initialLocation: CompleteRequestLocation?,
        initialAddress: String?,
        searchAddressUseCase: SearchAddressUseCaseProtocol,
        reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol,
        locationProvider: CompleteRequestLocationProviderProtocol
    ) {
        self.searchAddressUseCase = searchAddressUseCase
        self.reverseGeocodeAddressUseCase = reverseGeocodeAddressUseCase
        self.locationProvider = locationProvider
        addressText = initialLocation?.address
            ?? initialAddress?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ""

        let coordinate = initialLocation.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        } ?? CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357)
        selectedCoordinate = initialLocation == nil ? nil : coordinate
        let initialRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        )
        region = initialRegion
        cameraPosition = .region(initialRegion)
    }

    var canConfirm: Bool {
        selectedCoordinate != nil
            && !addressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isResolvingAddress
    }

    func resolveInitialAddressIfNeeded() async {
        let initialAddress = addressText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard selectedCoordinate == nil, !initialAddress.isEmpty else { return }

        isResolvingAddress = true
        defer { isResolvingAddress = false }

        guard let result = try? await searchAddressUseCase.execute(
            query: initialAddress,
            region: region
        ).first else {
            return
        }
        selectSearchResult(result)
    }

    func scheduleSearch() {
        searchTask?.cancel()
        locationErrorMessage = nil

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            guard let self, !Task.isCancelled else { return }
            await self.performSearch(query: query)
        }
    }

    func selectSearchResult(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        selectedCoordinate = coordinate
        addressText = item.placemark.title ?? item.name ?? ""
        searchText = ""
        searchResults = []
        moveCamera(to: coordinate)
    }

    func selectPin(at coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        moveCamera(to: coordinate)
        resolveAddress(for: coordinate)
    }

    func useCurrentLocation() async {
        locationErrorMessage = nil
        do {
            let coordinate = try await locationProvider.currentCoordinate()
            selectedCoordinate = coordinate
            moveCamera(to: coordinate)
            resolveAddress(for: coordinate)
        } catch CompleteRequestLocationProviderError.permissionDenied {
            locationErrorMessage = "address.permission_denied".localized
        } catch {
            locationErrorMessage = "complete_request.location.unavailable".localized
        }
    }

    func confirmLocation() -> CompleteRequestLocation? {
        guard canConfirm, let selectedCoordinate else { return nil }
        return CompleteRequestLocation(
            address: addressText.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: selectedCoordinate.latitude,
            longitude: selectedCoordinate.longitude
        )
    }

    private func performSearch(query: String) async {
        isSearching = true
        defer { isSearching = false }

        do {
            let results = try await searchAddressUseCase.execute(query: query, region: region)
            guard !Task.isCancelled else { return }
            searchResults = results
        } catch {
            guard !Task.isCancelled else { return }
            locationErrorMessage = "complete_request.location.search_error".localized
        }
    }

    private func resolveAddress(for coordinate: CLLocationCoordinate2D) {
        geocodeTask?.cancel()
        geocodeTask = Task { [weak self] in
            guard let self else { return }
            self.isResolvingAddress = true
            defer { self.isResolvingAddress = false }

            do {
                let address = try await self.reverseGeocodeAddressUseCase.execute(coordinate: coordinate)
                guard !Task.isCancelled else { return }
                self.addressText = address
            } catch {
                guard !Task.isCancelled else { return }
                self.locationErrorMessage = "complete_request.location.resolve_error".localized
            }
        }
    }

    private func moveCamera(to coordinate: CLLocationCoordinate2D) {
        region.center = coordinate
        withAnimation(.easeInOut(duration: 0.25)) {
            cameraPosition = .region(region)
        }
    }
}
