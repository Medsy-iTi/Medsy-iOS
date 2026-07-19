//
//  ProfileView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @ObservedObject private var appSettings = PharmacyAppSettings.shared
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        ScrollView {
            content
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.top, PharmacySpacing.sm)
                .padding(.bottom, PharmacySpacing.xl)
        }
        .background(PharmacyColor.bg)
        .refreshable { await viewModel.refresh() }
        .navigationTitle("profile_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: PharmacySpacing.md) {
                    if let profile = viewModel.profile, profile.pharmacyId != nil {
                        Button {
                            viewModel.didTapPharmacyCard()
                        } label: {
                            Image(systemName: "building.2")
                                .foregroundStyle(PharmacyColor.textPrimary)
                        }
                        .accessibilityLabel("pharmacy_profile_title".localized)
                    }
                    
                    Button {
                        viewModel.didTapSettings()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(PharmacyColor.textPrimary)
                    }
                    .accessibilityLabel("settings_title".localized)
                }
            }
        }
        .task { await viewModel.onAppear() }
        .confirmationDialog(
            "logout_confirmation_title".localized,
            isPresented: $viewModel.showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("logout_confirm_action".localized, role: .destructive) {
                Task { await viewModel.confirmLogout() }
            }
            Button("cancel".localized, role: .cancel) {
                viewModel.cancelLogout()
            }
        } message: {
            Text("logout_confirmation_message".localized)
        }
        .overlay {
            if viewModel.isLoggingOut {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView()
                        .padding(PharmacySpacing.md)
                        .background(PharmacyColor.surface, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProfileLoadingView()

        case .error(let message):
            ProfileErrorView(message: message) {
                Task { await viewModel.onAppear() }
            }

        case .loaded:
            if let profile = viewModel.profile {
                loadedContent(profile: profile)
            }
        }
    }

    @ViewBuilder
    private func loadedContent(profile: PharmacyProfile) -> some View {
        VStack(spacing: PharmacySpacing.md) {
            PharmacyInfoCardView(profile: profile)



            ProfileSectionContainer {
                Menu {
                    Button {
                        viewModel.setLanguage(.english)
                    } label: {
                        HStack {
                            Text("english".localized)
                            if languageManager.currentLanguage == .english {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        viewModel.setLanguage(.arabic)
                    } label: {
                        HStack {
                            Text("arabic".localized)
                            if languageManager.currentLanguage == .arabic {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } label: {
                    ProfileMenuRow(
                        icon: "globe",
                        title: "language_title".localized,
                        subtitle: languageManager.currentLanguage == .arabic ? "arabic".localized : "english".localized
                    )
                }

                ProfileRowDivider()

                Menu {
                    Button {
                        viewModel.setTheme(isDark: false)
                    } label: {
                        HStack {
                            Text("theme_light".localized)
                            if !appSettings.isDarkMode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        viewModel.setTheme(isDark: true)
                    } label: {
                        HStack {
                            Text("theme_dark".localized)
                            if appSettings.isDarkMode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } label: {
                    ProfileMenuRow(
                        icon: "moon.stars.fill",
                        iconTint: PharmacyColor.secondary,
                        title: "theme_title".localized,
                        subtitle: appSettings.isDarkMode ? "theme_dark".localized : "theme_light".localized
                    )
                }
            }

            ProfileSectionContainer {
                ProfileNavigationRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    iconTint: PharmacyColor.danger,
                    title: "logout_title".localized,
                    action: viewModel.requestLogout
                )
            }
        }
    }
}
