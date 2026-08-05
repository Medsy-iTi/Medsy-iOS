//
//  OrderFilterChipBar.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrderFilterChipBar: View {
    let filters: [OrderFilter]
    @Binding var selected: OrderFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MedsySpacing.xs) {
                ForEach(filters) { filter in
                    chip(filter)
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.vertical, MedsySpacing.xs)
        }
    }

    @ViewBuilder
    private func chip(_ filter: OrderFilter) -> some View {
        let isSelected = selected == filter
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selected = filter
            }
        } label: {
            Text(filter.labelKey.localized)
                .font(AppColor.sans(14, isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? AppColor.white : AppColor.textPrim)
                .padding(.horizontal, MedsySpacing.md)
                .padding(.vertical, MedsySpacing.xxs + 2)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColor.green : AppColor.card)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : AppColor.border, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var filter: OrderFilter = .all
    OrderFilterChipBar(filters: OrderFilter.allCases, selected: $filter)
        .background(AppColor.bg)
}
