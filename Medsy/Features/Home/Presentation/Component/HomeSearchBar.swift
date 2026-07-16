//  HomeSearchBar.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeSearchBar: View {
    @Environment(LanguageManager.self) private var languageManager
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("home.searchPlaceholder".localized)
                    .font(AppColor.sans(14))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(languageManager.isRTL ? .trailing : .leading)

                Spacer()

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColor.textSec)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.border, lineWidth: 1)
                .background(AppColor.card.cornerRadius(12))
        )
        .padding(.horizontal)
    }
}
