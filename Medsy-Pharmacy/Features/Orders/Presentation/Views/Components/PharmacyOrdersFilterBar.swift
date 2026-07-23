//
//  PharmacyOrdersFilterBar.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersFilterBar: View {
    @Binding var selection: PharmacyOrdersFilter
	let allCount: Int
	let newCount: Int
	let preparingCount: Int
	let deliveredCount: Int
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PharmacySpacing.xs) {
                ForEach(PharmacyOrdersFilter.allCases) { filter in
                    PharmacyOrdersFilterButton(
                        filter: filter,
                        count: badgeCount(for: filter),
                        isSelected: selection == filter,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selection = filter
                            }
                        }
                    )
                }
            }
        }
        .accessibilityLabel("pharmacy.orders.filters".localized)
    }

	private func badgeCount(for filter: PharmacyOrdersFilter) -> Int? {
		switch filter {
			case .all: allCount > 0 ? allCount : nil
			case .new: newCount > 0 ? newCount : nil
			case .preparing: preparingCount > 0 ? preparingCount : nil
			case .delivered: deliveredCount > 0 ? deliveredCount : nil
		}
	}
}
