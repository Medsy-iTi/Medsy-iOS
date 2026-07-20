//
//  SettingsView.swift
//  Medsy-Pharmacy
//
//  Settings Screen
//

import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = PharmacyAppSettings.shared
    let onBack: () -> Void

    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        VStack(spacing: 1) {
                            // Language
                            Menu {
                                Button {
                                    languageManager.set(.english)
                                } label: {
                                    HStack {
                                        Text("english".localized)
                                        if languageManager.currentLanguage == .english {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                Button {
                                    languageManager.set(.arabic)
                                } label: {
                                    HStack {
                                        Text("arabic".localized)
                                        if languageManager.currentLanguage == .arabic {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            } label: {
                                MenuRow(
                                    icon: "globe",
                                    title: "language_title".localized,
                                    subtitle: languageManager.currentLanguage == .arabic
                                        ? "arabic".localized
                                        : "english".localized
                                ) {
                                    // No action, menu handles it
                                }
                            }

                            // Theme
                            Menu {
                                Button {
                                    appSettings.isDarkMode = false
                                } label: {
                                    HStack {
                                        Text("theme_light".localized)
                                        if !appSettings.isDarkMode { Image(systemName: "checkmark") }
                                    }
                                }
                                Button {
                                    appSettings.isDarkMode = true
                                } label: {
                                    HStack {
                                        Text("theme_dark".localized)
                                        if appSettings.isDarkMode { Image(systemName: "checkmark") }
                                    }
                                }
                            } label: {
                                MenuRow(
                                    icon: "moon.stars.fill",
                                    title: "theme_title".localized,
                                    subtitle: appSettings.isDarkMode
                                        ? "theme_dark".localized
                                        : "theme_light".localized
                                ) {
                                    // No action, menu handles it
                                }
                            }
                        }
                        .background(PharmacyColor.border.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg))
                        .overlay(
                            RoundedRectangle(cornerRadius: PharmacyRadius.lg)
                                .stroke(PharmacyColor.border, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.top, PharmacySpacing.sm)
                    .padding(.bottom, PharmacySpacing.xl)
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(PharmacyColor.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Text("settings_title".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)
            
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }
}

#Preview {
    SettingsView(onBack: {})
}
