//
//  CompleteRequestLocationPickerViewModelProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import CoreLocation
import MapKit
import _MapKit_SwiftUI

@MainActor
protocol CompleteRequestLocationPickerViewModelProtocol: AnyObject {
    var searchText: String { get set }
    var addressText: String { get }
    var searchResults: [MKMapItem] { get }
    var cameraPosition: MapCameraPosition { get set }
    var selectedCoordinate: CLLocationCoordinate2D? { get }
    var isSearching: Bool { get }
    var isResolvingAddress: Bool { get }
    var locationErrorMessage: String? { get }
    var canConfirm: Bool { get }

    func resolveInitialAddressIfNeeded() async
    func scheduleSearch()
    func selectSearchResult(_ item: MKMapItem)
    func selectPin(at coordinate: CLLocationCoordinate2D)
    func useCurrentLocation() async
    func confirmLocation() -> CompleteRequestLocation?
}
