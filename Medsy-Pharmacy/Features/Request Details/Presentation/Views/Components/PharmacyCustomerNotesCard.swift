//
//  PharmacyCustomerNotesCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyCustomerNotesCard: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text("pharmacy.request.customer_notes_header".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            HStack {
                Text(notes.isEmpty ? "pharmacy.request.no_customer_notes".localized : notes)
                    .font(PharmacyColor.sans(14, .regular))
                    .foregroundStyle(PharmacyColor.textSecondary)

                Spacer()
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )
        }
    }
}
