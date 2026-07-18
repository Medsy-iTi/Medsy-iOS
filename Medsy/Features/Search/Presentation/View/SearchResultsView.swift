//
//  SearchResultsView.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct SearchResultsView: View {
	@StateObject private var viewModel: SearchResultsViewModel
	@Environment(LanguageManager.self) private var languageManager
	@ObservedObject private var appSettings = AppSettings.shared
	private let coordinator: SearchCoordinator
	private let onBack: () -> Void

	@State private var showSortSheet = false

	init(query: String, onBack: @escaping () -> Void = {}, coordinator: SearchCoordinator) {
		_viewModel = StateObject(wrappedValue: SearchResultsViewModel(query: query))
		self.onBack = onBack
		self.coordinator = coordinator
	}

	var body: some View {
		VStack(spacing: 0) {
			header

			VStack(spacing: MedsySpacing.sm) {
				SearchBar(
					text: $viewModel.query,
					placeholder: "search.placeholder".localized
				) {
					viewModel.load()
				}

				ChipsRow {

					FilterChip(
						title: sortChipTitle,
						systemIcon: "slider.horizontal.3",
						isSelected: viewModel.selectedSort != nil
					) {
						showSortSheet = true
					}


				}

				if viewModel.state == .loaded {
					Text("search.result_count".localized(viewModel.products.count))
						.font(MedsyFont.caption())
						.foregroundStyle(AppColor.textSec)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			.padding(.horizontal, MedsySpacing.md)
			.padding(.top, MedsySpacing.sm)

			content
		}
		.background(AppColor.bg.ignoresSafeArea())
		.localizedEnvironment()
		.id("\(languageManager.currentLanguage)-\(appSettings.isDarkMode)")
		.onAppear { viewModel.load() }
		.sheet(isPresented: $showSortSheet) {
			SortFilterSheet(viewModel: viewModel, isPresented: $showSortSheet)
		}
	}

	// MARK: – Computed

	private var sortChipTitle: String {
		guard let active = viewModel.selectedSort else {
			return "filter.sort".localized
		}
		let match = SortOption.all.first { $0.sort == active }
		return match?.labelKey.localized ?? "filter.sort".localized
	}

	// MARK: – Subviews

	private var header: some View {
		HStack {
			Button {
				onBack()
			} label: {
				Image(systemName: languageManager.isRTL ? "arrow.right" : "arrow.left")
					.foregroundStyle(AppColor.textPrim)
					.imageScale(.large)
			}
			.frame(width: 44, height: 44)

			Spacer()

			Text("search.title".localized)
				.font(MedsyFont.title())
				.foregroundStyle(AppColor.textPrim)

			Spacer()

			Color.clear.frame(width: 44)
		}
		.padding(.horizontal, MedsySpacing.md)
		.frame(height: 56)
		.background(AppColor.bg)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.state {
			case .loading:
				ScrollView {
					MedsySkeletonList().padding(MedsySpacing.md)
				}

			case .loaded:
				ScrollView {
					LazyVStack(spacing: MedsySpacing.sm) {
						ForEach($viewModel.products) { $product in
							SearchedProductCard(product: $product, onTap: {
								coordinator.showProductDetail(productId: product.id)
							})
							.onAppear {
								viewModel.loadNextPageIfNeeded(currentItem: product)
							}
						}
					}
					.padding(MedsySpacing.md)
				}
				
			case .empty:
				MedsyStatusView(
					config: .noResults(
						onClear: { viewModel.clearSearch() },
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
