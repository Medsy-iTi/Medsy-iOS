//
//  ThemeSelectionView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//

import SwiftUI


struct ThemeSelectionView: View {
    @ObservedObject var appSettings: PharmacyAppSettings

    var body: some View {
        List {
            row(title: "theme_light".localized, isSelected: !appSettings.isDarkMode) {
                appSettings.isDarkMode = false
            }
            row(title: "theme_dark".localized, isSelected: appSettings.isDarkMode) {
                appSettings.isDarkMode = true
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("theme_title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(PharmacyColor.sans(15, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(PharmacyColor.primary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
