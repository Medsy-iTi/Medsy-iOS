//
//  PharmacyPrescriptionCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyPrescriptionCard: View {
    let uiImage: UIImage?
    var imageUrl: URL? = nil
    let onEnlarge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            PharmacySectionHeader(
                title: "pharmacy.request.customer_prescription".localized,
                systemImage: "doc.text.image.fill"
            )

            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .fill(PharmacyColor.mutedSurface)
                    .frame(height: 150)

                if let uiImage = uiImage {
                    PharmacyAuthenticatedAsyncImage(uiImage: uiImage) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                } else if let url = imageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundStyle(PharmacyColor.textSecondary.opacity(0.3))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .pharmacyCard(padding: nil, elevation: .subtle)
            .contentShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .onTapGesture {
                onEnlarge()
            }
            .accessibilityAddTraits(.isButton)
        }
    }
}
