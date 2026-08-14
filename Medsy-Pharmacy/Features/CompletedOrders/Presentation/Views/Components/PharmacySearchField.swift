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
    @FocusState private var isFocused: Bool

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
                .foregroundStyle(PharmacyColor.textPrimary)
                .focused($isFocused)

            Image(systemName: "magnifyingglass")
                .foregroundStyle(PharmacyColor.primary)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .frame(minHeight: 50)
        .pharmacyInputSurface(isFocused: isFocused)
    }
}

#Preview {
    PharmacySearchField(text: .constant(""), placeholder: "orders_search_placeholder".localized, onFilterTap: {})
        .padding()
        .background(PharmacyColor.bg)
}
