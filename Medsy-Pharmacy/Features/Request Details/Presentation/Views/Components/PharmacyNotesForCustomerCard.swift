//
//  PharmacyNotesForCustomerCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyNotesForCustomerCard: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text("pharmacy.request.notes_for_customer_header".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            TextField("pharmacy.request.notes_for_customer_placeholder".localized, text: $text, axis: .vertical)
                .lineLimit(2...4)
                .font(PharmacyColor.sans(14, .regular))
                .padding(14)
                .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                        .stroke(PharmacyColor.border, lineWidth: 1)
                )
        }
    }
}
