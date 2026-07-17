//
//  SortFilterSheet.swift
//  Medsy
//

import SwiftUI



struct SortOption: Identifiable, Equatable {
    let id: String
    let labelKey: String
    let sort: ProductSort

    static let all: [SortOption] = [
        SortOption(id: "price_asc",  labelKey: "sort.price_asc",  sort: ProductSort(field: .price, direction: .asc)),
        SortOption(id: "price_desc", labelKey: "sort.price_desc", sort: ProductSort(field: .price, direction: .desc)),
        SortOption(id: "name_asc",   labelKey: "sort.name_asc",   sort: ProductSort(field: .name,  direction: .asc)),
        SortOption(id: "name_desc",  labelKey: "sort.name_desc",  sort: ProductSort(field: .name,  direction: .desc)),
        SortOption(id: "scientific_name_asc",   labelKey: "sort.scientific_name_asc",   sort: ProductSort(field: .scientificName,  direction: .asc)),
        SortOption(id: "company_asc",   labelKey: "sort.company_asc",   sort: ProductSort(field: .company,  direction: .asc)),
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

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    

                    if !viewModel.categories.isEmpty {
                        Text("categories.title".localized)
                            .font(MedsyFont.bodyMedium(13))
                            .foregroundStyle(AppColor.textSec)
                            .padding(.horizontal, MedsySpacing.md)
                            .padding(.bottom, MedsySpacing.xs)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MedsySpacing.sm) {
                                ForEach(viewModel.categories) { category in
                                    categoryChip(category)
                                }
                            }
                            .padding(.horizontal, MedsySpacing.md)
                        }
                        .padding(.bottom, MedsySpacing.md)
                    }

                    // Sort options
                    Text("filter.sort_by".localized)
                        .font(MedsyFont.bodyMedium(13))
                        .foregroundStyle(AppColor.textSec)
                        .padding(.horizontal, MedsySpacing.md)
                        .padding(.bottom, MedsySpacing.xs)

                    ForEach(SortOption.all) { option in
                        sortRow(option)
                    }
                }
            }

            Spacer()


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
                        .background(
                            RoundedRectangle(cornerRadius: MedsyRadius.md)
                                .stroke(AppColor.danger, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.md)
            }
        }
        .background(AppColor.bg)
        .localizedEnvironment()
        .presentationDetents([.medium, .large])
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
            .background(
                RoundedRectangle(cornerRadius: MedsyRadius.md)
                    .fill(isActive ? AppColor.green.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.md)
                    .stroke( AppColor.green , lineWidth: 1)
            )
            .padding(.horizontal, MedsySpacing.md)
            .padding(.bottom, MedsySpacing.xs)
        }
        .buttonStyle(.plain)
    }

    private func categoryChip(_ category: Category) -> some View {
        let isActive = viewModel.selectedCategory?.id == category.id
        return Button {
            viewModel.selectedCategory = isActive ? nil : category
        } label: {
            HStack(spacing: MedsySpacing.xxs) {
                Image(systemName: category.iconName)
                    .font(.system(size: 14))
                Text(category.displayName)
                    .font(MedsyFont.bodyMedium(14))
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.vertical, 8)
            .foregroundStyle(isActive ? .white : AppColor.textPrim)
            .background(
                Capsule()
                    .fill(isActive ? AppColor.green : AppColor.surface)
            )
            .overlay(
                Capsule()
                    .stroke(AppColor.green , lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
