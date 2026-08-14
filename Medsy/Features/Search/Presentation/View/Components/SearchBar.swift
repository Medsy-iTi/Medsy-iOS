//
//  SearchBar.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        HStack(spacing: MedsySpacing.xs) {
            searchIcon

            TextField("", text: $text, prompt: 
                Text(placeholder).foregroundStyle(AppColor.textSec)
            )
                .font(MedsyFont.body())
                .foregroundStyle(AppColor.textPrim)
                .localizedTextInput()
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }

            clearButton
        }
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: MedsyRadius.pill)
                .fill(isFocused ? AppColor.green.opacity(0.05) : AppColor.card)
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.pill)
                        .stroke( AppColor.green , lineWidth: 1)
                )
        )
    }

   

    @ViewBuilder
    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .foregroundStyle(isFocused ? AppColor.green : AppColor.textSec)
    }

    @ViewBuilder
    private var clearButton: some View {
        if !text.isEmpty {
            Button {
                text = ""
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColor.textSec)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(AppColor.surface))
            }
            .accessibilityLabel(Text("empty.clear_search".localized))
        }
    }
}
