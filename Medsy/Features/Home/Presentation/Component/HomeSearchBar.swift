//  HomeSearchBar.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeSearchBar: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var searchText = ""
    let onSubmit: (String) -> Void
    
    var body: some View {
        HStack {
            TextField("", text: $searchText, prompt: 
                Text("home.searchPlaceholder".localized)
                    .foregroundStyle(AppColor.textSec)
            )
            .font(AppColor.sans(14))
            .foregroundStyle(AppColor.textPrim)
            .multilineTextAlignment(languageManager.isRTL ? .trailing : .leading)
            .submitLabel(.search)
            .onSubmit { onSubmit(searchText) }
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textSec)
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
