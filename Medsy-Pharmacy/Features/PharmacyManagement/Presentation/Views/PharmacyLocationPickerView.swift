//
//  PharmacyLocationPickerView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import MapKit
import SwiftUI

struct PharmacyLocationPickerView: View {
    @State private var position: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D
    let onBack: () -> Void
    let onConfirm: (Double, Double) -> Void

    init(
        latitude: Double?,
        longitude: Double?,
        onBack: @escaping () -> Void,
        onConfirm: @escaping (Double, Double) -> Void
    ) {
        let coordinate = CLLocationCoordinate2D(
            latitude: latitude ?? 30.04442,
            longitude: longitude ?? 31.23571
        )
        _selectedCoordinate = State(initialValue: coordinate)
        _position = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                )
            )
        )
        self.onBack = onBack
        self.onConfirm = onConfirm
    }

    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $position) {
                    Marker("pharmacy.management.map.marker".localized, coordinate: selectedCoordinate)
                        .tint(PharmacyColor.primary)
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .onTapGesture { point in
                    if let coordinate = proxy.convert(point, from: .local) {
                        selectedCoordinate = coordinate
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                PharmacyManagementHeader(
                    title: "pharmacy.management.map.title".localized,
                    subtitle: "pharmacy.management.map.subtitle".localized,
                    onBack: onBack
                )
                .padding(PharmacySpacing.md)
                .background(.ultraThinMaterial)

                Spacer()

                VStack(spacing: PharmacySpacing.md) {
                    HStack(spacing: PharmacySpacing.sm) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(PharmacyColor.primary)

                        Text(String(format: "%.5f, %.5f", selectedCoordinate.latitude, selectedCoordinate.longitude))
                            .font(PharmacyColor.sans(13, .semibold))
                            .foregroundStyle(PharmacyColor.textPrimary)

                        Spacer()
                    }

                    PharmacyPrimaryButton(
                        title: "pharmacy.management.map.confirm".localized,
                        systemImage: "checkmark",
                        action: {
                            onConfirm(selectedCoordinate.latitude, selectedCoordinate.longitude)
                        }
                    )
                }
                .padding(PharmacySpacing.md)
                .background(PharmacyColor.surface)
            }
        }
    }
}

#Preview {
    PharmacyLocationPickerView(
        latitude: nil,
        longitude: nil,
        onBack: {},
        onConfirm: { _, _ in }
    )
    .environment(LanguageManager.shared)
    .pharmacyLocalizedEnvironment()
}
