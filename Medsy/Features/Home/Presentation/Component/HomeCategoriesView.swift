//  HomeCategoriesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

import SwiftUI

struct HomeCategoriesView: View {
    @State private var viewModel: CategoriesViewModel

    init(viewModel: CategoriesViewModel = DIContainer.shared.resolve(CategoriesViewModel.self)) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("home.shopByCategories".localized)
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                NavigationLink(destination: CategoriesView()) {
                    Text("home.viewAll".localized)
                        .font(AppColor.sans(13, .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(.horizontal)

            switch viewModel.state {
            case .loading:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(0..<5, id: \.self) { _ in
                            VStack(spacing: 8) {
                                MedsySkeletonBlock(cornerRadius: 16, height: 58, width: 58)
                                MedsySkeletonBlock(cornerRadius: 4, height: 12, width: 50)
                            }
                            .frame(width: 80)
                        }
                    }
                    .padding(.horizontal)
                }
            case .success:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(viewModel.categories) { category in
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(category.bgColor)
                                        .frame(width: 58, height: 58)

                                    Image(systemName: category.iconName)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(category.iconColor)
                                }

                                Text(category.displayName)
                                    .font(AppColor.sans(11, .medium))
                                    .foregroundStyle(AppColor.textPrim)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 76)
                            }
                            .frame(width: 80)
                        }
                    }
                    .padding(.horizontal)
                }
            case .error:
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.loadCategories()
                        }
                    }) {
                        Label("error.retry".localized, systemImage: "arrow.clockwise")
                            .font(AppColor.sans(13, .bold))
                            .foregroundStyle(AppColor.green)
                    }
                    Spacer()
                }
                .frame(height: 80)
            }
        }
        .task {
            await viewModel.loadCategories()
        }
    }
}
