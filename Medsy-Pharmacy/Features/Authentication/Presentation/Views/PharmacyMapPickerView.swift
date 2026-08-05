import CoreLocation
import MapKit
import SwiftUI

struct PharmacyMapPickerView: View {
    @Bindable var viewModel: PharmacySetupViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition

    init(viewModel: PharmacySetupViewModel) {
        self.viewModel = viewModel
        let coordinate = CLLocationCoordinate2D(
            latitude: viewModel.location?.latitude ?? 30.0444,
            longitude: viewModel.location?.longitude ?? 31.2357
        )
        _selectedCoordinate = State(initialValue: viewModel.location.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        })
        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            map

            VStack(spacing: PharmacySpacing.sm) {
                Text("pharmacy.setup.map.hint".localized)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.state == .resolvingLocation {
                    ProgressView("pharmacy.setup.location.resolving".localized)
                        .tint(PharmacyColor.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let location = viewModel.location {
                    PharmacySetupReadOnlyField(
                        title: "pharmacy.setup.location.selected".localized,
                        value: location.address,
                        systemImage: "mappin.and.ellipse"
                    )
                }

                PharmacyPrimaryButton(
                    title: "pharmacy.setup.map.confirm".localized,
                    isDisabled: selectedCoordinate == nil || viewModel.location == nil || viewModel.state == .resolvingLocation
                ) {
                    dismiss()
                }
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.surface)
        }
        .background(PharmacyColor.bg)
        .navigationTitle("pharmacy.setup.location.map".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "common.error".localized,
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.dismissError() } }
            )
        ) {
            Button("common.ok".localized) { viewModel.dismissError() }
        } message: {
            if let message = viewModel.alertMessage { Text(message) }
        }
    }

    private var map: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                if let selectedCoordinate {
                    Marker("pharmacy.setup.map.pin".localized, coordinate: selectedCoordinate)
                        .tint(PharmacyColor.primary)
                }
                UserAnnotation()
            }
            .mapControls {
                MapCompass()
                MapScaleView()
                MapUserLocationButton()
            }
            .simultaneousGesture(
                SpatialTapGesture().onEnded { value in
                    guard let coordinate = proxy.convert(value.location, from: .local) else { return }
                    selectedCoordinate = coordinate
                    Task {
                        await viewModel.selectMapCoordinate(
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        )
                    }
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("pharmacy.setup.map.accessibility".localized)
    }
}
