//
//  PharmacyOrderSearchField.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrderSearchField: View {
    @Binding var text: String
    let onClear: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PharmacyColor.primaryDark)

            TextField("pharmacy.orders.search".localized, text: $text)
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .frame(height: 22)

            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(PharmacyColor.primaryDark)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("pharmacy.orders.filters".localized)
        }
        .padding(.horizontal, PharmacySpacing.sm)
        .frame(minHeight: 48)
        .pharmacyInputSurface(isFocused: isFocused)
    }
}
