//  HomeCategoriesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct HomeCategoriesView: View {
    @State private var viewModel: CategoriesViewModel
    @State private var hasLoadedCategories = false

    private var visibleCategories: [Category] {
        Array(viewModel.categories.prefix(9))
    }

    init(viewModel: CategoriesViewModel = DIContainer.shared.resolve(CategoriesViewModel.self)) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: MedsySpacing.md) {
            HStack {
                Text("home.shopByCategories".localized)
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                NavigationLink(destination: CategoriesView()) {
                    Text("home.viewAll".localized)
                        .font(AppColor.sans(13, .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(.horizontal)

            switch viewModel.state {
            case .loading:
                Grid(horizontalSpacing: MedsySpacing.sm, verticalSpacing: MedsySpacing.md) {
                    ForEach(0..<3, id: \.self) { row in
                        GridRow {
                            ForEach(0..<3, id: \.self) { column in
                                VStack(spacing: MedsySpacing.xs) {
                                    MedsySkeletonBlock(cornerRadius: MedsyRadius.lg, height: 96)
                                    MedsySkeletonBlock(cornerRadius: MedsyRadius.sm, height: 12, width: 70)
                                }
                                .frame(maxWidth: .infinity)
                                .accessibilityHidden(true)
                                .id(row * 3 + column)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            case .success:
                Grid(horizontalSpacing: MedsySpacing.sm, verticalSpacing: MedsySpacing.md) {
                    ForEach(0..<3, id: \.self) { row in
                        GridRow {
                            ForEach(0..<3, id: \.self) { column in
                                let index = row * 3 + column
                                if visibleCategories.indices.contains(index) {
                                    let category = visibleCategories[index]
                                    NavigationLink(destination: ProductsView(category: category)) {
                                        CategoryGridCard(category: category, artworkHeight: 96)
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity)
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 138)
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            case .error:
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.loadCategories()
                        }
                    }) {
                        Label("error.retry".localized, systemImage: "arrow.clockwise")
                            .font(AppColor.sans(13, .bold))
                            .foregroundStyle(AppColor.green)
                    }
                    Spacer()
                }
                .frame(height: 80)
            }
        }
        .task {
            guard !hasLoadedCategories else { return }
            hasLoadedCategories = true
            await viewModel.loadCategories()
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}
