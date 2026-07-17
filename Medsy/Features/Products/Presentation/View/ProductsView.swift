//  ProductsView.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct ProductsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProductsViewModel

    init(category: Category) {
        _viewModel = State(initialValue: ProductsViewModel(category: category))
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .loading:
                ScrollView(showsIndicators: false) {
                    MedsySkeletonList(rowCount: 6)
                        .padding()
                }
            case .success:
                if viewModel.products.isEmpty {
                    MedsyStatusView(
                        config: MedsyStatusConfig(
                            systemIcon: "magnifyingglass",
                            iconColor: { AppColor.textSec },
                            iconBackground: { AppColor.surface },
                            title: "empty.title".localized,
                            subtitle: "empty.subtitle".localized,
                            primaryButtonTitle: "error.retry".localized,
                            primaryAction: {
                                Task {
                                    await viewModel.loadProducts()
                                }
                            }
                        )
                    )
                } else {
                    @Bindable var viewModel = viewModel
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach($viewModel.products) { $product in
                                SearchedProductCard(
                                    product: $product,
                                    onAdd: {},
                                    onIncrement: {},
                                    onDecrement: {},
                                    onToggleFavorite: {},
                                    onTap: {}
                                )
                                .onAppear {
                                    if product.id == viewModel.products.last?.id {
                                        Task {
                                            await viewModel.loadNextPage()
                                        }
                                    }
                                }
                            }

                            if viewModel.isFetchingNextPage {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .tint(AppColor.green)
                                    Spacer()
                                }
                                .padding(.vertical, 16)
                            }
                        }
                        .padding()
                    }
                }
            case .error:
                MedsyStatusView(
                    config: .noConnection {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                )
            }
        }
        .background(AppColor.bg)
        .navigationTitle(viewModel.category.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColor.textPrim)
                }
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}
