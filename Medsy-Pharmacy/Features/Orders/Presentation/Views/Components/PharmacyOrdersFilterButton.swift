//
//  PharmacyOrdersFilterButton.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersFilterButton: View {
    let filter: PharmacyOrdersFilter
    let count: Int?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(filter.titleKey.localized)

                if let count {
                    Text("\(count)")
                        .font(PharmacyColor.sans(11, .bold))
                }
            }
            .font(PharmacyColor.sans(12, .semibold))
            .foregroundStyle(isSelected ? .white : PharmacyColor.textPrimary)
            .padding(.horizontal, 13)
            .frame(height: 38)
            .background(
                isSelected ? PharmacyColor.primary : PharmacyColor.card,
                in: Capsule()
            )
            .overlay {
                if !isSelected {
                    Capsule().stroke(PharmacyColor.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
