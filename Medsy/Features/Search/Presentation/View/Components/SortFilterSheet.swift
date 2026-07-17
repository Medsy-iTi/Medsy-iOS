//
//  SortFilterSheet.swift
//  Medsy
//

import SwiftUI

// MARK: - Sort Option definition used by the sheet

struct SortOption: Identifiable, Equatable {
    let id: String
    let labelKey: String
    let sort: ProductSort

    static let all: [SortOption] = [
        SortOption(id: "price_asc",  labelKey: "sort.price_asc",  sort: ProductSort(field: .price, direction: .asc)),
        SortOption(id: "price_desc", labelKey: "sort.price_desc", sort: ProductSort(field: .price, direction: .desc)),
        SortOption(id: "name_asc",   labelKey: "sort.name_asc",   sort: ProductSort(field: .name,  direction: .asc)),
        SortOption(id: "name_desc",  labelKey: "sort.name_desc",  sort: ProductSort(field: .name,  direction: .desc)),
    ]
}

// MARK: - Sheet

struct SortFilterSheet: View {
    @ObservedObject var viewModel: SearchResultsViewModel
    @Binding var isPresented: Bool
    @Environment(\.layoutDirection) private var layoutDirection
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Handle
            Capsule()
                .fill(AppColor.border)
                .frame(width: 40, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, MedsySpacing.sm)
                .padding(.bottom, MedsySpacing.md)

            // Title
            Text("filter.sort_title".localized)
                .font(MedsyFont.title())
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, MedsySpacing.md)

            Divider()
                .padding(.vertical, MedsySpacing.sm)

            // Sort options
            Text("filter.sort_by".localized)
                .font(MedsyFont.bodyMedium(13))
                .foregroundStyle(AppColor.textSec)
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.xs)

            ForEach(SortOption.all) { option in
                sortRow(option)
            }

            Spacer()

            // Clear button
            if viewModel.selectedSort != nil {
                Button {
                    viewModel.selectedSort = nil
                    isPresented = false
                } label: {
                    Text("filter.clear".localized)
                        .font(MedsyFont.bodyMedium(16))
                        .foregroundStyle(AppColor.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MedsySpacing.sm)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.xs)
            }
        }
        .background(AppColor.bg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    private func sortRow(_ option: SortOption) -> some View {
        let isActive = viewModel.selectedSort == option.sort
        return Button {
            viewModel.toggleSort(option.sort)
            isPresented = false
        } label: {
            HStack {
                Text(option.labelKey.localized)
                    .font(MedsyFont.body())
                    .foregroundStyle(isActive ? AppColor.green : AppColor.textPrim)
                Spacer()
                if isActive {
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppColor.green)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.vertical, MedsySpacing.sm)
            .background(isActive ? AppColor.green.opacity(0.08) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}
