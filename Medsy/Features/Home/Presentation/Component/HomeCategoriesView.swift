//  HomeCategoriesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct HomeCategoriesView: View {
    private let categories: [Category]

    private var visibleCategories: [Category] {
        Array(categories.prefix(9))
    }

    init(categories: [Category] = HomeFeaturedCategoryCatalog.categories) {
        self.categories = categories
    }

    var body: some View {
        VStack(spacing: MedsySpacing.md) {
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

            Grid(horizontalSpacing: MedsySpacing.sm, verticalSpacing: MedsySpacing.md) {
                ForEach(0..<3, id: \.self) { row in
                    GridRow {
                        ForEach(0..<3, id: \.self) { column in
                            let index = row * 3 + column
                            if visibleCategories.indices.contains(index) {
                                let category = visibleCategories[index]
                                NavigationLink(destination: ProductsView(category: category)) {
                                    CategoryGridCard(category: category, artworkHeight: 96)
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 138)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
}
