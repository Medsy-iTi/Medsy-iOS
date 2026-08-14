//
//  PharmacyNotesForCustomerCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyNotesForCustomerCard: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            PharmacySectionHeader(
                title: "pharmacy.request.notes_for_customer_header".localized,
                systemImage: "square.and.pencil"
            )

            TextField("pharmacy.request.notes_for_customer_placeholder".localized, text: $text, axis: .vertical)
                .lineLimit(2...4)
                .font(PharmacyColor.sans(14, .regular))
                .padding(14)
                .focused($isFocused)
                .pharmacyInputSurface(isFocused: isFocused)
        }
    }
}
