//
//  MedsyPharmacyRow.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI

/// A single row in a "pharmacies near me" list — name, open/closed pill,
/// distance info, and call / directions buttons.
struct MedsyPharmacyRow: View {
    var iconName: String = "cross.case.fill"
    var name: String
    var openStatus: String
    var openStatusColor: Color = .green
    var distanceInfo: String

    var accentColor: Color = MedsyTheme.default.primary

    var onCall: () -> Void = {}
    var onDirections: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(accentColor.opacity(0.12))
                Image(systemName: iconName)
                    .foregroundColor(accentColor)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                    Text(openStatus)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(openStatusColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(openStatusColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                Text(distanceInfo)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: onCall) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(accentColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button(action: onDirections) {
                Image(systemName: "location.fill")
                    .foregroundColor(accentColor)
                    .padding(8)
                    .overlay(Circle().stroke(accentColor.opacity(0.3)))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    VStack(spacing: 4) {
        MedsyPharmacyRow(name: "El Ezaby Pharmacy", openStatus: "Open 24h", distanceInfo: "350 m · 12 Nile St. · ~4 min walk")
        Divider()
        MedsyPharmacyRow(name: "Misr Pharmacy", openStatus: "Open", distanceInfo: "600 m · Road 9 · closes 12 AM")
    }
    .padding()
}