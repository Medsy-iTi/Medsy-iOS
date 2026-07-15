//
//  SearchResultsView.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI


struct SearchResultsView: View {
    @StateObject private var viewModel: SearchResultsViewModel

    init(query: String) {
        _viewModel = StateObject(wrappedValue: SearchResultsViewModel(query: query))
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(spacing: MedsySpacing.sm) {
                SearchBar(text: $viewModel.query, placeholder: NSLocalizedString("search.placeholder", comment: "")) {
                    viewModel.load()
                }

                MedsyChipsRow {
                    MedsyFilterChip(title: NSLocalizedString("filter.sort", comment: ""), systemIcon: "slider.horizontal.3") {}
                    MedsyFilterChip(title: NSLocalizedString("filter.type", comment: "")) {}
                    MedsyFilterChip(title: NSLocalizedString("filter.price", comment: "")) {}
                    MedsyFilterChip(
                        title: NSLocalizedString("filter.most_relevant", comment: ""),
                        isSelected: viewModel.selectedFilter == "relevant"
                    ) {
                        viewModel.selectedFilter = "relevant"
                    }
                }

                if viewModel.state == .loaded {
					Text(String(format: NSLocalizedString("search.result_count", comment: ""), viewModel.products.count))
                        .font(MedsyFont.caption())
                        .foregroundStyle(AppColor.textSec)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.top, MedsySpacing.sm)

            content


        }
        .background(AppColor.bg.ignoresSafeArea())
        .onAppear { viewModel.load() }
    }

	private var header: some View {
		HStack {
			Button {
					// TODO: Add back navigation if needed
			} label: {
				Image(systemName: "arrow.forward")
					.foregroundStyle(AppColor.textPrim)
					.imageScale(.large)
			}
			.frame(width: 44, height: 44)

			Spacer()

			Text(NSLocalizedString("search.title", comment: ""))
				.font(MedsyFont.title())
				.foregroundStyle(AppColor.textPrim)

			Spacer()

			Color.clear.frame(width: 44)
		}
		.padding(.horizontal, MedsySpacing.md)
		.frame(height: 56)                    // Fixed compact height
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
                       SearchedProductCard(product: $product)
                    }
                }
                .padding(MedsySpacing.md)
            }

        case .empty:
            MedsyStatusView(
                config: .noResults(
                    onClear: { viewModel.clearSearch() },
                    onPrescription: {
						
					}
                )
            )

        case .noConnection:
            MedsyStatusView(
                config: .noConnection(onRetry: { viewModel.load() })
            )
        }
    }
}

