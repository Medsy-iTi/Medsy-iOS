//  HomeSearchBar.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeSearchBar: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared
    let onTap: () -> Void

    private var searchBackground: Color {
        appSettings.isDarkMode ? Color(hex: "#1A2920") : Color(hex: "#FFFFFF")
    }

    private var searchBorder: Color {
        appSettings.isDarkMode ? Color(hex: "#283D32") : Color(white: 0, opacity: 0.08)
    }

    private var searchContentColor: Color {
        appSettings.isDarkMode ? Color(hex: "#9CA3AF") : Color(hex: "#6B7280")
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("home.searchPlaceholder".localized)
                    .font(AppColor.sans(14))
                    .foregroundStyle(searchContentColor)
                    .multilineTextAlignment(languageManager.isRTL ? .trailing : .leading)

                Spacer()

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(searchContentColor)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(searchBorder, lineWidth: 1)
                .background(searchBackground.cornerRadius(12))
        )
        .padding(.horizontal)
    }
}
