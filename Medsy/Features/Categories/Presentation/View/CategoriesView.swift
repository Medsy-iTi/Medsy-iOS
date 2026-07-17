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

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
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
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(0..<8, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 12) {
                                MedsySkeletonBlock(cornerRadius: 16, height: 50, width: 50)
                                MedsySkeletonBlock(cornerRadius: 4, height: 16, width: 100)
                                MedsySkeletonBlock(cornerRadius: 4, height: 12, width: 60)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(AppColor.card)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AppColor.border, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            case .success:
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredCategories) { category in
                            NavigationLink(destination: ProductsView(category: category)) {
                                CategoryGridCard(
                                    titleKey: category.displayName,
                                    iconName: category.iconName,
                                    iconColor: category.iconColor,
                                    bgColor: category.bgColor,
                                )
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
        .navigationTitle("categories.title".localized)
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
            await viewModel.loadCategories()
        }
    }
}
