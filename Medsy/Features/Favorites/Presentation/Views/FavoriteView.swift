//
//  FavoriteView.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import SwiftUI

struct FavoriteView: View {
    @State private var viewModel: FavoriteViewModel
    @State private var medicinePendingRemoval: FavoriteMedicineDisplayModel?
    @Environment(CartViewModel.self) private var cartViewModel

    private let onBack: () -> Void
    private let onBrowse: () -> Void
    private let onSelectMedicine: (String) -> Void
    private let columns = Array(repeating: GridItem(.flexible(), spacing: MedsySpacing.sm, alignment: .top), count: 2)

    init(
        viewModel: FavoriteViewModel = DIContainer.shared.resolve(FavoriteViewModel.self),
        onBack: @escaping () -> Void,
        onBrowse: @escaping () -> Void,
        onSelectMedicine: @escaping (String) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _medicinePendingRemoval = State(initialValue: nil)
        self.onBack = onBack
        self.onBrowse = onBrowse
        self.onSelectMedicine = onSelectMedicine
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            MedsyNavBar(title: "favorites.title".localized)
            content
        }
        .background(AppColor.bg.ignoresSafeArea())
        .onAppear { Task { await viewModel.load() } }
        .confirmationAlert(
            item: $medicinePendingRemoval,
            configuration: ConfirmationAlert(
                title: "favorites.remove_confirmation.title".localized,
                message: { "favorites.remove_confirmation.message".localized($0.title) },
                confirmButtonTitle: "favorites.remove_confirmation.action".localized,
                cancelButtonTitle: "common.cancel".localized,
                confirmRole: .destructive,
                onConfirm: { product in
                    Task { await viewModel.remove(product) }
                }
            )
        )
        .alert("favorites.offline.title".localized, isPresented: $viewModel.isShowingOfflineAlert) {
            Button("common.ok".localized, role: .cancel) {}
        } message: {
            Text("favorites.offline.subtitle".localized)
        }
        .alert(
            "favorites.persistence_error.title".localized,
            isPresented: Binding(
                get: { viewModel.persistenceErrorMessage != nil },
                set: { if !$0 { viewModel.persistenceErrorMessage = nil } }
            )
        ) {
            Button("common.ok".localized, role: .cancel) { viewModel.persistenceErrorMessage = nil }
        } message: {
            Text(viewModel.persistenceErrorMessage ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: MedsySpacing.sm) {
                    ForEach(0..<6, id: \.self) { _ in FavoriteMedicineCardSkeleton() }
                }
                .padding(MedsySpacing.sm)
            }
        case let .loaded(products):
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: MedsySpacing.sm) {
                    ForEach(products) { product in
                        FavoriteMedicineCard(
                            product: product,
                            quantity: cartQuantity(for: product),
                            onToggleFavorite: { medicinePendingRemoval = product },
                            onAdd: { addOneToCart(product) },
                            onIncrement: { addOneToCart(product) },
                            onDecrement: {
                                guard let itemID = cartViewModel.itemID(forProductID: Int64(product.id)) else { return }
                                cartViewModel.handle(.decreaseQuantity(itemID: itemID))
                            },
                            onTap: {
                                guard let productID = viewModel.detailDestination(for: product.id) else { return }
                                onSelectMedicine(productID)
                            }
                        )
                    }
                }
                .padding(MedsySpacing.sm)
            }
            .refreshable { await viewModel.load() }
        case .empty:
            FavoriteEmptyStateView(onBrowse: onBrowse)
        case let .failed(message):
            MedsyStatusView(config: MedsyStatusConfig(
                systemIcon: "exclamationmark.triangle",
                iconColor: { AppColor.danger },
                iconBackground: { AppColor.danger.opacity(0.12) },
                title: "favorites.error.title".localized,
                subtitle: message,
                primaryButtonTitle: "error.retry".localized,
                primaryAction: { Task { await viewModel.load() } }
            ))
        }
    }

    private func addOneToCart(_ product: FavoriteMedicineDisplayModel) {
        cartViewModel.handle(.addItem(FavoriteCartItemPresentationMapper.map(product)))
    }

    private func cartQuantity(for product: FavoriteMedicineDisplayModel) -> Int {
        cartViewModel.quantity(forProductID: Int64(product.id))
    }
}

private struct FavoriteEmptyStateView: View {
    let onBrowse: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.md) {
            Spacer(minLength: MedsySpacing.xxl)

            MedsyLottieView(
                animationName: "favorites_empty"
            )
            .frame(width: 220, height: 220)
            .accessibilityHidden(true)

            VStack(spacing: MedsySpacing.xs) {
                Text("favorites.empty.title".localized)
                    .font(MedsyFont.title(22))		
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.center)

                Text("favorites.empty.subtitle".localized)
                    .font(MedsyFont.body(16))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(
                title: "favorites.empty.action".localized,
                systemImage: "magnifyingglass",
                action: onBrowse
            )
            .padding(.top, MedsySpacing.md)

            Spacer(minLength: MedsySpacing.lg)
        }
        .padding(.horizontal, MedsySpacing.md)
    }
}
