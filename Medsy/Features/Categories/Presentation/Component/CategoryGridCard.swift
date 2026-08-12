//
//  CategoryGridCard.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI

struct CategoryGridCard: View {
    enum Style {
        case home
        case listing
    }

    let category: Category
    let style: Style
    @ObservedObject private var appSettings = AppSettings.shared

    init(category: Category, style: Style = .listing) {
        self.category = category
        self.style = style
    }

    var body: some View {
        VStack(spacing: MedsySpacing.xs) {
            CategoryArtworkView(category: category)
                .frame(height: style == .home ? 96 : 90)

            Text(category.displayName)
                .font(AppColor.sans(13, .semibold))
                .foregroundStyle(AppColor.textPrim)
                .lineLimit(style == .home ? 1 : 4)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: style == .home ? 20 : 34, alignment: .top)
        }
        .padding(style == .listing ? MedsySpacing.md : 0)
        .frame(maxWidth: .infinity, minHeight: style == .home ? 124 : 156, alignment: .top)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            if style == .listing || style == .home {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: style == .home ? 0.5 : 1)
            }
        }
        .shadow(
            color: shadowColor,
            radius: style == .home ? 12 : 8,
            y: 4
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(category.displayName)
    }

    private var cardBackground: Color {
        switch style {
        case .home:
            return appSettings.isDarkMode ? Color(hex: "#0E1418") : Color(hex: "#FFFFFF")
        case .listing:
            return AppColor.card
        }
    }

    private var borderColor: Color {
        switch style {
        case .home:
            return AppColor.green.opacity(appSettings.isDarkMode ? 0.18 : 0.08)
        case .listing:
            return AppColor.green.opacity(0.22)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .home:
            return AppColor.green.opacity(appSettings.isDarkMode ? 0.18 : 0.12)
        case .listing:
            return AppColor.green.opacity(0.14)
        }
    }
}
