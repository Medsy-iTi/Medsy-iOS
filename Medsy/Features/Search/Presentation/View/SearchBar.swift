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

    var body: some View {
        HStack(spacing: MedsySpacing.xs) {
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
                .accessibilityLabel(Text("empty.clear_search"))
            }

            TextField(placeholder, text: $text)
                .font(MedsyFont.body())
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.trailing)  
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }

            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textSec)
        }
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: MedsyRadius.pill)
                .fill(AppColor.card)
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.pill)
						.stroke(AppColor.border, lineWidth: 1)
                )
        )
    }
}

