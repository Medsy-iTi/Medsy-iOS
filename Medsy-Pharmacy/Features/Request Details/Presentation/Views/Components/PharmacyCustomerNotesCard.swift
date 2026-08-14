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
            PharmacySectionHeader(
                title: "pharmacy.request.customer_notes_header".localized,
                systemImage: "text.bubble.fill"
            )

            HStack {
                Text(notes.isEmpty ? "pharmacy.request.no_customer_notes".localized : notes)
                    .font(PharmacyColor.sans(14, .regular))
                    .foregroundStyle(PharmacyColor.textSecondary)

                Spacer()
            }
            .pharmacyCard(elevation: .subtle)
        }
    }
}
