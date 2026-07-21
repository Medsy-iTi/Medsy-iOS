//  PharmacyLocationCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI
import MapKit

struct PharmacyLocationCardView: View {
    let address: String
    let latitude: Double
    let longitude: Double
    let onOpenDirections: () -> Void

    @State private var position: MapCameraPosition

    init(address: String, latitude: Double, longitude: Double, onOpenDirections: @escaping () -> Void) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.onOpenDirections = onOpenDirections
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        _position = State(initialValue: .region(region))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.green)

                Text("pharmacyProfile.location".localized)
                    .font(MedsyFont.title(16))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()
            }

            Map(position: $position) {
                Marker(
                    address,
                    systemImage: "cross.case.fill",
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                )
                .tint(AppColor.green)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))

            HStack(alignment: .top, spacing: MedsySpacing.xs) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColor.green)
                    .padding(.top, 2)

                Text(address)
                    .font(MedsyFont.body(14))
                    .foregroundStyle(AppColor.textSec)
                    .lineLimit(2)

                Spacer()

                Button(action: onOpenDirections) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(.top, 4)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}
