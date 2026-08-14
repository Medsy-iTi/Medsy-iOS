//
//  ProfileBlockingProgressOverlay.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfileBlockingProgressOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()

            ProgressView()
                .tint(PharmacyColor.primary)
                .pharmacyCard(elevation: .raised)
        }
    }
}
