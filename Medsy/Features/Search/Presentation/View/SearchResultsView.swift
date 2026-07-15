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

    init(query: String) {
        _viewModel = StateObject(wrappedValue: SearchResultsViewModel(query: query))
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
                    FilterChip(title: "filter.sort".localized, systemIcon: "slider.horizontal.3") {}
                    FilterChip(title: "filter.type".localized) {}
                    FilterChip(title: "filter.price".localized) {}
                    FilterChip(
                        title: "filter.most_relevant".localized,
                        isSelected: viewModel.selectedFilter == "relevant"
                    ) {
                        viewModel.selectedFilter = "relevant"
                    }
                }

                if viewModel.state == .loaded {
                    Text("search.result_count".localized(viewModel.products.count))
                        .font(MedsyFont.caption())
                        .foregroundStyle(AppColor.textSec)

                        .frame(maxWidth: .infinity, alignment: languageManager.isRTL ? .leading : .trailing)
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
    }


    private var header: some View {
        HStack {
            Button {

            } label: {

                Image(systemName: languageManager.isRTL ? "arrow.forward" : "arrow.backward")
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
                        SearchedProductCard(product: $product)
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
