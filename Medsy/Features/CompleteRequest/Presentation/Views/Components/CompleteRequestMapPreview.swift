//
//  CompleteRequestMapPreview.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import MapKit
import SwiftUI

struct CompleteRequestMapPreview: View {
    let location: CompleteRequestLocation

    var body: some View {
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )

        Map(initialPosition: .region(region), interactionModes: []) {
            Marker("complete_request.location.pin".localized, coordinate: coordinate)
                .tint(AppColor.green)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
        .allowsHitTesting(false)
        .accessibilityLabel("complete_request.location.preview".localized)
    }
}
