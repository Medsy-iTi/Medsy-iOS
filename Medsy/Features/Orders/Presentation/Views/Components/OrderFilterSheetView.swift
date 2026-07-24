//
//  OrderFilterSheetView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 24/07/2026.
//

import SwiftUI

struct OrderFilterSheetView: View {
    @State private var draft: ActiveOrderFilters
    let onApply: (ActiveOrderFilters) -> Void

    init(current: ActiveOrderFilters, onApply: @escaping (ActiveOrderFilters) -> Void) {
        _draft = State(initialValue: current)
        self.onApply = onApply
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: MedsySpacing.xl) {
                    fulfillmentSection
                    Divider().background(AppColor.border)
                    dateRangeSection
                }
                .padding(.horizontal, MedsySpacing.md)
                .padding(.top, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.xxl + 80)
            }
            .background(AppColor.bg)
            .navigationTitle("orders.filter.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("orders.filter.reset".localized) {
                        draft = .default
                    }
                    .foregroundStyle(AppColor.green)
                    .disabled(!draft.hasActiveFilters)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("orders.filter.apply".localized) {
                        onApply(draft)
                    }
                    .font(AppColor.sans(15, .semibold))
                    .foregroundStyle(AppColor.green)
                }
            }
        }
    }

    private var fulfillmentSection: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Text("orders.filter.section.fulfillment".localized)
                .font(AppColor.sans(14, .semibold))
                .foregroundStyle(AppColor.textSec)
            HStack(spacing: MedsySpacing.xs) {
                fulfillmentChip(nil, labelKey: "orders.filter.fulfillment.all")
                fulfillmentChip(.delivery, labelKey: "orders.filter.fulfillment.delivery")
                fulfillmentChip(.pickup, labelKey: "orders.filter.fulfillment.pickup")
            }
        }
    }

    @ViewBuilder
    private func fulfillmentChip(_ type: OrderFulfillmentType?, labelKey: String) -> some View {
        let isSelected = draft.fulfillmentType == type
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                draft.fulfillmentType = type
            }
        } label: {
            Text(labelKey.localized)
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

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Text("orders.filter.section.date".localized)
                .font(AppColor.sans(14, .semibold))
                .foregroundStyle(AppColor.textSec)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MedsySpacing.xs) {
                    ForEach(OrderDateRangeFilter.allCases) { range in
                        dateRangeChip(range)
                    }
                }
                .padding(.horizontal, MedsySpacing.md)
                .padding(.vertical, MedsySpacing.xxs)
            }
            .padding(.horizontal, -MedsySpacing.md)

            if draft.dateRangeFilter == .custom {
                customDatePickers
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: draft.dateRangeFilter)
    }

    @ViewBuilder
    private func dateRangeChip(_ range: OrderDateRangeFilter) -> some View {
        let isSelected = draft.dateRangeFilter == range
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                draft.dateRangeFilter = range
                if range != .custom {
                    draft.customDateFrom = nil
                    draft.customDateTo = nil
                }
            }
        } label: {
            Text(range.labelKey.localized)
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

    private var customDatePickers: some View {
        VStack(spacing: MedsySpacing.sm) {
            DatePicker(
                "orders.filter.date.from".localized,
                selection: Binding(
                    get: { draft.customDateFrom ?? Date() },
                    set: { draft.customDateFrom = $0 }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            .tint(AppColor.green)

            DatePicker(
                "orders.filter.date.to".localized,
                selection: Binding(
                    get: { draft.customDateTo ?? Date() },
                    set: { draft.customDateTo = $0 }
                ),
                in: (draft.customDateFrom ?? .distantPast)...Date(),
                displayedComponents: .date
            )
            .tint(AppColor.green)
        }
        .font(AppColor.sans(14, .regular))
        .foregroundStyle(AppColor.textPrim)
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    OrderFilterSheetView(current: .default) { _ in }
        .environment(LanguageManager.shared)
}
