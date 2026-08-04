//  HomeCategoriesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct HomeCategoriesView: View {
    @State private var viewModel: CategoriesViewModel

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: MedsySpacing.sm, alignment: .top),
        count: 3
    )

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
                LazyVGrid(columns: columns, spacing: MedsySpacing.md) {
                    ForEach(0..<9, id: \.self) { _ in
                        VStack(spacing: MedsySpacing.xs) {
                            MedsySkeletonBlock(cornerRadius: MedsyRadius.lg, height: 96)
                            MedsySkeletonBlock(cornerRadius: MedsyRadius.sm, height: 12, width: 70)
                        }
                    }
                }
                .padding(.horizontal)
            case .success:
                LazyVGrid(columns: columns, spacing: MedsySpacing.md) {
                    ForEach(Array(viewModel.categories.prefix(9))) { category in
                        NavigationLink(destination: ProductsView(category: category)) {
                            CategoryGridCard(category: category)
                        }
                        .buttonStyle(.plain)
                    }
                }
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
            await viewModel.loadCategories()
        }
    }
}
