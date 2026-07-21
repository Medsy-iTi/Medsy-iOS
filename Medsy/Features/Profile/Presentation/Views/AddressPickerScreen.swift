//
//  AddressPickerScreen.swift
//  Medsy
//
//  Created by Shahudaa on 20/07/2026.
//



import SwiftUI
import MapKit

struct AddressPickerScreen: View {

    let initialAddress: String
    let initialCoordinate: CLLocationCoordinate2D?
    let onConfirm: (String, CLLocationCoordinate2D) -> Void
    let onCancel: () -> Void

    @State private var region: MKCoordinateRegion
    @State private var searchText: String = ""
    @State private var addressText: String

    private static let defaultCoordinate = CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357) // Cairo fallback
    private static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)

    init(
        initialAddress: String = "",
        initialCoordinate: CLLocationCoordinate2D? = nil,
        onConfirm: @escaping (String, CLLocationCoordinate2D) -> Void = { _, _ in },
        onCancel: @escaping () -> Void = {}
    ) {
        self.initialAddress = initialAddress
        self.initialCoordinate = initialCoordinate
        self.onConfirm = onConfirm
        self.onCancel = onCancel

        let coordinate = initialCoordinate ?? AddressPickerScreen.defaultCoordinate
        _region = State(initialValue: MKCoordinateRegion(center: coordinate, span: AddressPickerScreen.defaultSpan))
        _addressText = State(initialValue: initialAddress)
    }

    var body: some View {
        ZStack {
            ProfileStyle.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MedsyNavBar(title: "address.title".localized, onBack: onCancel)

                searchField
                mapSection
                addressField
                confirmButton
            }
        }
    }

    // MARK: - Search

    private var searchField: some View {
        // View only — bind a search completer / results list here later.
        CustomTextField(title: "address.search_placeholder".localized, type: .address, text: $searchText)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
    }

    // MARK: - Map

    private var mapSection: some View {
        Map(coordinateRegion: $region)
            // View only — no drag-end / reverse-geocode call wired up.
            .overlay {
                Image(systemName: "mappin")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(ProfileStyle.red)
                    .offset(y: -17) // tip of the pin sits on the exact center
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }
            .padding(.horizontal, 20)
    }

    // MARK: - Address text + confirm

    private var addressField: some View {
        // View only — plain editable field, not auto-filled from the map yet.
        CustomTextField(title: "profile.home_address.placeholder".localized, type: .address, text: $addressText)
            .padding(.horizontal, 20)
            .padding(.top, 14)
    }

    private var confirmButton: some View {
        PrimaryButton(
            title: "address.confirm".localized,
            isDisabled: addressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            onConfirm(addressText, region.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 20)
    }
}

#Preview {
    AddressPickerScreen(
        initialAddress: "",
        onConfirm: { _, _ in },
        onCancel: {}
    )
    .environment(LanguageManager.shared)
}
