//
//  PharmacySearchField.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

struct PharmacySearchField: View {
    @Binding var text: String
    var placeholder: String
    var onFilterTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            if let onFilterTap {
                Button(action: onFilterTap) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(PharmacyColor.primary)
                }

                Divider()
                    .frame(height: 20)
            }

            TextField(placeholder, text: $text)
                .font(PharmacyColor.sans(15))
                .multilineTextAlignment(.trailing)

            Image(systemName: "magnifyingglass")
                .foregroundStyle(PharmacyColor.primary)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
        .background(PharmacyColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    PharmacySearchField(text: .constant(""), placeholder: "orders_search_placeholder".localized, onFilterTap: {})
        .padding()
        .background(PharmacyColor.bg)
}
