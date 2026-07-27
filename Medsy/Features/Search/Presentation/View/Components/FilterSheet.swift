//
//  FilterSheet.swift
//  Medsy
//

import SwiftUI

struct FilterSheet: View {
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
            Text("filter.title".localized)
                .font(MedsyFont.title())
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, MedsySpacing.md)

            Divider()
                .padding(.vertical, MedsySpacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: MedsySpacing.md) {
                    
                    // Category Filter
                    if !viewModel.categories.isEmpty {
                        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                            Text("product.consumer_category".localized)
                                .font(MedsyFont.bodyMedium(15))
                                .foregroundStyle(AppColor.textPrim)
                                .padding(.horizontal, MedsySpacing.md)
                            
                            FlowLayout(spacing: MedsySpacing.sm) {
                                ForEach(viewModel.categories) { category in
                                    categoryChip(category)
                                }
                            }
                            .padding(.horizontal, MedsySpacing.md)
                        }
                    }

                    // Company Filter
                    VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                        Text("product.manufacturer".localized)
                            .font(MedsyFont.bodyMedium(15))
                            .foregroundStyle(AppColor.textPrim)
                            .padding(.horizontal, MedsySpacing.md)
                        
                        FlowLayout(spacing: MedsySpacing.sm) {
                            ForEach(viewModel.availableCompanies, id: \.self) { company in
                                companyChip(company)
                            }
                        }
                        .padding(.horizontal, MedsySpacing.md)
                    }
                }
            }

            Spacer()

            if viewModel.selectedCategory != nil || viewModel.selectedCompany != nil {
                Button {
                    viewModel.selectedCategory = nil
                    viewModel.selectedCompany = nil
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

    private func companyChip(_ company: String) -> some View {
        let isActive = viewModel.selectedCompany == company
        return Button {
            viewModel.selectedCompany = isActive ? nil : company
        } label: {
            Text(company)
                .font(MedsyFont.bodyMedium(14))
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
