//
//  ProductDetailView.swift
//  Medsy
//
//

import SwiftUI

struct ProductDetailView: View {
	@StateObject private var viewModel: ProductDetailViewModel
	@Environment(LanguageManager.self) private var languageManager
	@ObservedObject private var appSettings = AppSettings.shared
	@Environment(\.dismiss) private var dismiss

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
			}

			content
		}
		.background(AppColor.bg.ignoresSafeArea())
		.localizedEnvironment()
		.id("\(languageManager.currentLanguage)-\(appSettings.isDarkMode)")
		.onAppear { viewModel.load() }
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.state {
			case .loading:
				ScrollView {
					MedsyProductDetailSkeleton()
				}

			case .loaded:
				if let product = viewModel.product {
					ScrollView {
						VStack(spacing: MedsySpacing.md) {
							ImageCarousel(
								images: product.images,
								selectedIndex: $viewModel.selectedImageIndex,
								isFavorite: $viewModel.isFavorite
							)

							ProductHeaderInfo(
								title: product.title,
								subtitle: product.subtitle,
								price: product.price,
								currencyKey: product.currencyKey
							)

							if product.requiresPharmacistReview {
								WarningBanner(text: "product.pharmacist_review_notice".localized)
							}

							VStack(alignment: languageManager.isRTL ? .trailing : .leading, spacing: MedsySpacing.xs) {
								SectionHeader(title: "product.info_title".localized)
								Text(product.descriptionText)
									.font(MedsyFont.body(14))
									.foregroundStyle(AppColor.textSec)
									.multilineTextAlignment(languageManager.isRTL ? .trailing : .leading)
									.frame(maxWidth: .infinity, alignment: languageManager.isRTL ? .trailing : .leading)
							}

							MedsyInfoRowList(rows: product.infoRows)

							VStack(spacing: MedsySpacing.sm) {
								PrimaryButton(
									title: "product.add_to_cart".localized,
									systemImage: "cart",
									style: .primary
								) {
									viewModel.addToCart()
								}

								PrimaryButton(
									title: "product.consult_pharmacist".localized,
									systemImage: "bubble.left.and.bubble.right",
									style: .secondary
								) {
									viewModel.consultPharmacist()
								}
							}
							.padding(.top, MedsySpacing.xs)
						}
						.padding(MedsySpacing.md)
					}
				}

			case .empty:
				MedsyStatusView(
					config: .noResults(
						onClear: { viewModel.load() },
						onPrescription: {}
					)
				)

			case .noConnection:
				MedsyStatusView(
					config: .noConnection(onRetry: { viewModel.load() })
				)
		}
	}
}


