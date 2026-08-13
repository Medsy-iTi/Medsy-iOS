//
//  CompletedOrdersFilterBar.swift
//  Medsy
//

import SwiftUI

struct CompletedOrdersFilterBar: View {
    @Binding var selection: CompletedOrdersListFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PharmacySpacing.xs) {
                ForEach(CompletedOrdersListFilter.allCases) { filter in
                    CompletedOrdersFilterButton(
                        filter: filter,
                        isSelected: selection == filter,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selection = filter
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 1) // prevent clipping of capsule border
        }
        .accessibilityLabel("completed_orders.filter.all".localized)
    }
}

// MARK: - Filter Button

private struct CompletedOrdersFilterButton: View {
    let filter: CompletedOrdersListFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(filter.localizedTitle)
                .font(PharmacyColor.sans(12, .semibold))
                .foregroundStyle(isSelected ? .white : PharmacyColor.textPrimary)
                .padding(.horizontal, 11)
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
