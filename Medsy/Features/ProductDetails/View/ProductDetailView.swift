//
//  ProductDetailView.swift
//  Medsy
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(LanguageManager.self) private var languageManager
    @Environment(CartViewModel.self) private var cartViewModel
    @ObservedObject private var appSettings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openChatbotPrompt) private var openChatbotPrompt

    init(productId: String) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: productId))
    }

    var body: some View {
        VStack(spacing: 0) {
            MedsyNavBar(onBack: { dismiss() }) {
                Button {

                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(AppColor.textPrim)
                        .imageScale(.large)
                }
                .accessibilityLabel("accessibility.share".localized)
            }

            content
        }
        .background(AppColor.bg.ignoresSafeArea())
        .localizedEnvironment()
        .id(languageManager.currentLanguage)
        .onAppear { viewModel.load() }
        .alert(
            "favorites.persistence_error.title".localized,
            isPresented: Binding(
                get: { viewModel.favoriteErrorMessage != nil },
                set: { if !$0 { viewModel.favoriteErrorMessage = nil } }
            )
        ) {
            Button("common.ok".localized, role: .cancel) {
                viewModel.favoriteErrorMessage = nil
            }
        } message: {
            Text(viewModel.favoriteErrorMessage ?? "")
        }
    }

    // MARK: - Content switcher

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ScrollView {
                MedsyProductDetailSkeleton()
            }

        case .loaded:
            if let product = viewModel.product {
                loadedContent(product: product)
            } else {
                MedsyStatusView(
                    config: .productNotFound(onSearch: { dismiss() })
                )
            }

        case .empty:
            MedsyStatusView(
                config: .productNotFound(onSearch: { dismiss() })
            )

        case .noConnection:
            MedsyStatusView(
                config: .noConnection(onRetry: { viewModel.load() })
            )

        case .error:
            MedsyStatusView(
                config: .productError(onRetry: { viewModel.load() })
            )
        }
    }

    // MARK: - Loaded content

    @ViewBuilder
    private func loadedContent(product: ProductDetailDisplayModel) -> some View {
        ScrollView {
            VStack(spacing: MedsySpacing.md) {

                ImageCarousel(
                    images: product.images,
                    selectedIndex: $viewModel.selectedImageIndex,
                    isFavorite: viewModel.isFavorite,
                    onToggleFavorite: viewModel.toggleFavorite
                )

                ProductHeaderInfo(
                    title: product.title,
                    subtitle: product.subtitle,
                    price: product.price,
                    currencyKey: product.currencyKey
                )
                .padding(.horizontal, MedsySpacing.md)


                    WarningBanner(text: "product.pharmacist_review_notice".localized)
                        .padding(.horizontal, MedsySpacing.md)
                

                VStack(
                    alignment: .leading,
                    spacing: MedsySpacing.xs
                ) {
                    SectionHeader(title: "product.info_title".localized)

                    Text(product.descriptionText)
                        .font(MedsyFont.body(14))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, MedsySpacing.md)

                MedsyInfoRowList(rows: product.infoRows)
                    .padding(.horizontal, MedsySpacing.md)

                VStack(spacing: MedsySpacing.sm) {
                    PrimaryButton(
                        title: "product.add_to_cart".localized,
                        systemImage: "cart",
                        style: .primary
                    ) {
                        cartViewModel.handle(
                            .addItem(CartItemPresentationMapper.map(product))
                        )
                    }

                    PrimaryButton(
                        title: "product.consult_pharmacist".localized,
                        systemImage: "bubble.left.and.bubble.right",
                        style: .secondary
                    ) {
                        openChatbotPrompt?("chatbot.consult_product_prompt".localized(product.title))
                    }
                }
                .padding(.horizontal, MedsySpacing.md)
                .padding(.top, MedsySpacing.xs)
            }
            .padding(.vertical, MedsySpacing.md)
        }
    }
}
