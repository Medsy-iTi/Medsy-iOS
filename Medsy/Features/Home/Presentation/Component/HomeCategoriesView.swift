//
//  HomeCategoriesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct HomeCategoriesView: View {
    private let categories: [Category]
    @ObservedObject private var appSettings = AppSettings.shared

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
                                    CategoryGridCard(category: category, style: .home)
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 130)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .padding(.top, MedsySpacing.md)
        .padding(.bottom, MedsySpacing.lg)
        .background(homeGridBackground)
        .id(appSettings.isDarkMode)
    }

    private var homeGridBackground: some View {
        ZStack {
            sectionBaseColor

            if appSettings.isDarkMode {
                LinearGradient(
                    colors: [
                        AppColor.green.opacity(0.12),
                        sectionBaseColor.opacity(0.97),
                        sectionBaseColor
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blur(radius: 20)
            } else {
                LinearGradient(
                    colors: [
                        Color(hex: "#EAF7F0"),
                        Color(hex: "#F6FBF8")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }

    private var sectionBaseColor: Color {
        appSettings.isDarkMode ? Color(hex: "#0B1014") : Color(hex: "#F6FBF8")
    }
}
