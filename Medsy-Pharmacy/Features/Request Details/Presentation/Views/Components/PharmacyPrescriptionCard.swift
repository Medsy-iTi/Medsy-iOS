//
//  PharmacyPrescriptionCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyPrescriptionCard: View {
    let uiImage: UIImage?
    let onEnlarge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text("pharmacy.request.customer_prescription".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .fill(PharmacyColor.mutedSurface)
                    .frame(height: 150)

                PharmacyAuthenticatedAsyncImage(uiImage: uiImage) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .onTapGesture {
                onEnlarge()
            }
        }
    }
}
