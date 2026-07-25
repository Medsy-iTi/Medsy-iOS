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
                .padding(PharmacySpacing.md)
                .background(
                    PharmacyColor.surface,
                    in: RoundedRectangle(cornerRadius: PharmacyRadius.md)
                )
        }
    }
}
