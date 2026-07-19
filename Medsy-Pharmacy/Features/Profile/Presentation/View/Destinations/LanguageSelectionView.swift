//
//  LanguageSelectionView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct LanguageSelectionView: View {
    @Bindable var languageManager: LanguageManager

    var body: some View {
        List {
            ForEach(PharmacyAppLanguage.allCases, id: \.self) { language in
                Button {
                    languageManager.set(language)
                } label: {
                    HStack {
                        Text(language == .arabic ? "arabic".localized : "english".localized)
                            .font(PharmacyColor.sans(15, .medium))
                            .foregroundStyle(PharmacyColor.textPrimary)
                        Spacer()
                        if languageManager.currentLanguage == language {
                            Image(systemName: "checkmark")
                                .foregroundStyle(PharmacyColor.primary)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("language_title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
