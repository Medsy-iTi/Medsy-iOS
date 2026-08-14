//  HomeSearchBar.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeSearchBar: View {
    @ObservedObject private var appSettings = AppSettings.shared
    let onTap: () -> Void

    private var searchBackground: Color {
        AppColor.surface
    }

    private var searchBorder: Color {
        AppColor.outlineVariant
    }

    private var searchContentColor: Color {
        AppColor.outline
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("home.searchPlaceholder".localized)
                    .font(AppColor.sans(14))
                    .foregroundStyle(searchContentColor)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(searchContentColor)
            }
        }
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
