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
                    VStack(spacing: 16) {
                        Spacer()
                        Text("products.empty_title".localized)
                            .font(AppColor.sans(16, .bold))
                            .foregroundStyle(AppColor.textPrim)
                        Text("products.empty_subtitle".localized)
                            .font(AppColor.sans(14))
                            .foregroundStyle(AppColor.textSec)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
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
                            }
                        }
                        .padding()
                    }
                }
            case .error:
                VStack(spacing: 16) {
                    Spacer()
                    Text("error.no_connection_title".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                    Button(action: {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }) {
                        Text("error.retry".localized)
                            .font(AppColor.sans(14, .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppColor.green.cornerRadius(12))
                    }
                    Spacer()
                }
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
