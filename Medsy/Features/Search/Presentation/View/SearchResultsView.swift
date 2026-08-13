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
	@Environment(CartViewModel.self) private var cartViewModel
	@ObservedObject private var appSettings = AppSettings.shared
	private let coordinator: SearchCoordinator
	private let onBack: () -> Void
	private let onSelect: ((MedsyProduct) -> Void)?

	@State private var showSortSheet = false
	@State private var showFilterSheet = false

	init(
		query: String,
		onBack: @escaping () -> Void = {},
		coordinator: SearchCoordinator,
		onSelect: ((MedsyProduct) -> Void)? = nil
	) {
		_viewModel = StateObject(wrappedValue: SearchResultsViewModel(query: query))
		self.onBack = onBack
		self.coordinator = coordinator
		self.onSelect = onSelect
	}

	var body: some View {
		VStack(spacing: 0) {
			MedsyNavBar(
				title: "search.title".localized,
				onBack: onBack
			)

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

					FilterChip(
						title: "filter.title".localized,
						systemIcon: "line.3.horizontal.decrease",
						isSelected: viewModel.selectedCategory != nil || viewModel.selectedCompany != nil
					) {
						showFilterSheet = true
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
		.sheet(isPresented: $showFilterSheet) {
			FilterSheet(viewModel: viewModel, isPresented: $showFilterSheet)
		}
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

	// MARK: – Computed

	private var sortChipTitle: String {
		guard let active = viewModel.selectedSort else {
			return "filter.sort".localized
		}
		let match = SortOption.all.first { $0.sort == active }
		return match?.labelKey.localized ?? "filter.sort".localized
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
							SearchedProductCard(
								product: $product,
								onAdd: {
									addOneToCart(product)
									product.quantity = cartQuantity(for: product)
								},
								onIncrement: {
									addOneToCart(product)
									product.quantity = cartQuantity(for: product)
								},
								onDecrement: {
									decreaseOneFromCart(product)
									product.quantity = cartQuantity(for: product)
								},
								onToggleFavorite: {
									viewModel.toggleFavorite(productID: product.id)
								},
								isSelectionMode: onSelect != nil,
								onTap: {
									if let onSelect {
										onSelect(product)
									} else {
										coordinator.showProductDetail(productId: product.id)
									}
								}
							)
							.onAppear {
								product.quantity = cartQuantity(for: product)
								viewModel.loadNextPageIfNeeded(currentItem: product)
							}
						}

						if viewModel.isLoadingNextPage {
							MedsySkeletonList(rowCount: 2)
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

	private func addOneToCart(_ product: MedsyProduct) {
		cartViewModel.handle(.addItem(CartItemPresentationMapper.map(product)))
	}

	private func cartQuantity(for product: MedsyProduct) -> Int {
		cartViewModel.quantity(forProductID: Int64(product.id))
	}

	private func decreaseOneFromCart(_ product: MedsyProduct) {
		guard let productID = Int64(product.id),
			  let cartItemID = cartViewModel.itemID(forProductID: productID) else {
			return
		}

		cartViewModel.handle(.decreaseQuantity(itemID: cartItemID))
	}
}
