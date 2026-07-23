//
//  PharmacyPrescriptionCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyPrescriptionCard: View {
    let imageUrl: String?
    let onEnlarge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text("pharmacy.request.customer_prescription".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .padding(.bottom, 2)

            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .fill(PharmacyColor.mutedSurface)
                    .frame(height: 150)

                VStack(spacing: 8) {
                    Image(systemName: "cross.case.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(PharmacyColor.primary.opacity(0.8))

                    Text("pharmacy.request.prescription_handwritten".localized)
                        .font(PharmacyColor.sans(14, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .onTapGesture {
                onEnlarge()
            }
        }
    }
}
