//
//  CartView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var state: CartViewState
    @State private var removedItem: CartDisplayItem?

    let onSearch: () -> Void
    let onUploadPrescription: () -> Void
    let onContinue: () -> Void
    let onItemCountChange: (Int) -> Void

    init(
        state: CartViewState = .loaded(CartSampleData.items),
        onSearch: @escaping () -> Void = {},
        onUploadPrescription: @escaping () -> Void = {},
        onContinue: @escaping () -> Void = {},
        onItemCountChange: @escaping (Int) -> Void = { _ in }
    ) {
        _state = State(initialValue: state)
        self.onSearch = onSearch
        self.onUploadPrescription = onUploadPrescription
        self.onContinue = onContinue
        self.onItemCountChange = onItemCountChange
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                MedsyNavBar(title: "cart.title".localized)

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.bg.ignoresSafeArea())

            if let removedItem {
                CartUndoBanner(
                    message: "cart.removed_message".localized(removedItem.name),
                    onUndo: restoreRemovedItem
                )
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .localizedEnvironment()
        .id(languageManager.currentLanguage)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .onAppear { onItemCountChange(currentItemCount) }
        .animation(.easeInOut(duration: 0.2), value: removedItem)
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            CartEmptyStateView(
                onSearch: onSearch,
                onUploadPrescription: onUploadPrescription
            )

        case let .error(message):
            MedsyStatusView(
                config: MedsyStatusConfig(
                    systemIcon: "exclamationmark.triangle",
                    iconColor: { AppColor.danger },
                    iconBackground: { AppColor.danger.opacity(0.12) },
                    title: "cart.error.title".localized,
                    subtitle: message,
                    primaryButtonTitle: "error.retry".localized,
                    primaryAction: restoreSampleCart
                )
            )

        case let .loaded(items):
            if items.isEmpty {
                CartEmptyStateView(
                    onSearch: onSearch,
                    onUploadPrescription: onUploadPrescription
                )
            } else {
                loadedContent(items: items)
            }
        }
    }

    private func loadedContent(items: [CartDisplayItem]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MedsySpacing.lg) {
                VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                    Text("cart.subtitle".localized)
                        .font(MedsyFont.title(24))
                        .foregroundStyle(AppColor.textPrim)

                    Text("cart.message".localized)
                        .font(MedsyFont.body(15))
                        .foregroundStyle(AppColor.textSec)
                }

                VStack(spacing: MedsySpacing.sm) {
                    ForEach(items) { item in
                        CartItemRow(
                            item: item,
                            onDecrease: { decreaseQuantity(for: item.id) },
                            onIncrease: { increaseQuantity(for: item.id) },
                            onRemove: { removeItem(id: item.id) }
                        )
                    }
                }

                CartTotalSummaryView(
                    estimatedTotal: estimatedTotal(items),
                    itemCount: items.count,
                    onContinue: onContinue
                )
                .padding(.top, MedsySpacing.xs)
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.top, MedsySpacing.md)
            .padding(.bottom, 112)
        }
    }

    private func increaseQuantity(for id: String) {
        updateLoadedItems { items in
            guard let index = items.firstIndex(where: { $0.id == id }) else { return }
            let item = items[index]
            items[index] = CartDisplayItem(
                id: item.id,
                name: item.name,
                dosageInfo: item.dosageInfo,
                unitPrice: item.unitPrice,
                quantity: item.quantity + 1,
                imageUrl: item.imageUrl
            )
        }
    }

    private func decreaseQuantity(for id: String) {
        guard case let .loaded(items) = state,
              let item = items.first(where: { $0.id == id }) else { return }

        if item.quantity <= 1 {
            removeItem(id: id)
        } else {
            updateLoadedItems { items in
                guard let index = items.firstIndex(where: { $0.id == id }) else { return }
                items[index] = CartDisplayItem(
                    id: item.id,
                    name: item.name,
                    dosageInfo: item.dosageInfo,
                    unitPrice: item.unitPrice,
                    quantity: item.quantity - 1,
                    imageUrl: item.imageUrl
                )
            }
        }
    }

    private func removeItem(id: String) {
        updateLoadedItems { items in
            guard let index = items.firstIndex(where: { $0.id == id }) else { return }
            removedItem = items.remove(at: index)
        }
    }

    private func restoreRemovedItem() {
        guard let removedItem else { return }
        updateLoadedItems { items in
            items.append(removedItem)
        }
        self.removedItem = nil
    }

    private func restoreSampleCart() {
        state = .loaded(CartSampleData.items)
    }

    private func updateLoadedItems(_ update: (inout [CartDisplayItem]) -> Void) {
        guard case var .loaded(items) = state else { return }
        update(&items)
        state = items.isEmpty ? .empty : .loaded(items)
        onItemCountChange(items.reduce(0) { $0 + $1.quantity })
    }

    private func estimatedTotal(_ items: [CartDisplayItem]) -> Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    private var currentItemCount: Int {
        guard case let .loaded(items) = state else { return 0 }
        return items.reduce(0) { $0 + $1.quantity }
    }
}

#Preview {
    CartView()
        .environment(LanguageManager())
}
