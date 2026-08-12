//  CategoriesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct CategoriesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var viewModel: CategoriesViewModel

    init(viewModel: CategoriesViewModel = DIContainer.shared.resolve(CategoriesViewModel.self)) {
        _viewModel = State(initialValue: viewModel)
    }

    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: MedsySpacing.sm, alignment: .top),
        count: 2
    )

    var body: some View {
        VStack(spacing: 0) {
            MedsyNavBar(title: "categories.title".localized, onBack: {dismiss()})
            HStack {
                TextField("", text: $searchText, prompt:
                    Text("categories.searchPlaceholder".localized)
                        .foregroundStyle(AppColor.textSec)
                )
                .font(AppColor.sans(14))
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.leading)

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColor.textSec)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColor.border, lineWidth: 1)
                    .background(AppColor.card.cornerRadius(12))
            )
            .padding()

            switch viewModel.state {
            case .loading:
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: MedsySpacing.md) {
                        ForEach(0..<8, id: \.self) { _ in
                            VStack(spacing: MedsySpacing.xs) {
                                MedsySkeletonBlock(cornerRadius: MedsyRadius.lg, height: 150)
                                MedsySkeletonBlock(cornerRadius: MedsyRadius.sm, height: 16, width: 110)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            case .success:
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: MedsySpacing.md) {
                        ForEach(filteredCategories) { category in
                            NavigationLink(destination: ProductsView(category: category)) {
                                CategoryGridCard(category: category)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if category == filteredCategories.last {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)


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
            case .error:
                VStack(spacing: 16) {
                    Spacer()
                    Text("error.no_connection_title".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                    Text("error.no_connection_subtitle".localized)
                        .font(AppColor.sans(14))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button(action: {
                        Task {
                            await viewModel.loadCategories()
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
                .padding(.bottom, 100)
            }
        }
        .background(AppColor.bg)
        .task {
            await viewModel.loadCategories()
        }
    }
}
