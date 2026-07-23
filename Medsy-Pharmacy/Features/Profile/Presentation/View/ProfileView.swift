//
//  ProfileView.swift
//  Medsy-Pharmacy
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
       
        .confirmationDialog(
            "pharmacy_card.leave_confirm_title".localized,
            isPresented: $viewModel.showLeavePharmacyConfirmation,
            titleVisibility: .visible
        ) {
            Button("pharmacy_card.leave_confirm_action".localized, role: .destructive) {
                Task { await viewModel.confirmLeavePharmacy() }
            }
            Button("cancel".localized, role: .cancel) {
                viewModel.cancelLeavePharmacy()
            }
        } message: {
            Text("pharmacy_card.leave_confirm_message".localized)
        }

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
        .confirmationDialog(
            "pharmacy_card.delete_confirm_title".localized,
            isPresented: $viewModel.showDeletePharmacyConfirmation,
            titleVisibility: .visible
        ) {
            Button("pharmacy_card.delete_confirm_action".localized, role: .destructive) {
                Task { await viewModel.confirmDeletePharmacy() }
            }
            Button("cancel".localized, role: .cancel) {
                viewModel.cancelDeletePharmacy()
            }
        } message: {
            Text("pharmacy_card.delete_confirm_message".localized)
        }
        .confirmationDialog(
            "pharmacy_team.remove_confirm_title".localized,
            isPresented: $viewModel.showRemovePharmacistConfirmation,
            titleVisibility: .visible
        ) {
            Button("pharmacy_team.remove_confirm_action".localized, role: .destructive) {
                Task { await viewModel.confirmRemovePharmacist() }
            }
            Button("cancel".localized, role: .cancel) {
                viewModel.cancelRemovePharmacist()
            }
        } message: {
            if let member = viewModel.selectedPharmacist {
                Text(String(format: "pharmacy_team.remove_confirm_message".localized, member.fullName))
            }
        }
        .overlay {
            if viewModel.isLoggingOut || viewModel.isLeavingPharmacy || viewModel.isDeletingPharmacy {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView()
                        .padding(PharmacySpacing.md)
                        .background(PharmacyColor.surface, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
                }
            }
        }
        .task { await viewModel.onAppear() }
    }

    // MARK: - Content

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

    // MARK: - Loaded

    @ViewBuilder
    private func loadedContent(profile: PharmacyProfile) -> some View {
        VStack(spacing: PharmacySpacing.md) {
            UserProfileView(profile: profile) {
                viewModel.didTapEditProfile()
            }

            ProfileSectionContainer {
                ProfileToggleRow(
                    icon: "stethoscope",
                    title: "profile.on_duty.title".localized,
                    badgeText: viewModel.isOnDuty
                        ? "profile.on_duty.on".localized
                        : "profile.on_duty.off".localized,
                    isLoading: viewModel.isDutyToggleLoading,
                    isOn: Binding(
                        get: { viewModel.isOnDuty },
                        set: { _ in Task { await viewModel.toggleDuty() } }
                    )
                )
            }

            pharmacySection(profile: profile)

            // Settings Section
            ProfileSectionContainer {
                // Language
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
                        subtitle: languageManager.currentLanguage == .arabic
                            ? "arabic".localized
                            : "english".localized
                    )
                }

                ProfileRowDivider()

                // Theme
                Menu {
                    Button {
                        viewModel.setTheme(isDark: false)
                    } label: {
                        HStack {
                            Text("theme_light".localized)
                            if !appSettings.isDarkMode { Image(systemName: "checkmark") }
                        }
                    }
                    Button {
                        viewModel.setTheme(isDark: true)
                    } label: {
                        HStack {
                            Text("theme_dark".localized)
                            if appSettings.isDarkMode { Image(systemName: "checkmark") }
                        }
                    }
                } label: {
                    ProfileMenuRow(
                        icon: "moon.stars.fill",
                        iconTint: PharmacyColor.secondary,
                        title: "theme_title".localized,
                        subtitle: appSettings.isDarkMode
                            ? "theme_dark".localized
                            : "theme_light".localized
                    )
                }
            }

            // Logout Section
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

    // MARK: - Pharmacy Section

    @ViewBuilder
    private func pharmacySection(profile: PharmacyProfile) -> some View {
        if profile.pharmacyId != nil {
            PharmacyProfileView(
                profile: profile,
                onEdit: profile.isPharmacyAdmin ? { viewModel.didTapEditPharmacy() } : nil,
                onInvite: profile.isPharmacyAdmin ? { viewModel.didTapInvitePharmacist() } : nil,
                onLeave: profile.isPharmacyAdmin ? nil : { viewModel.requestLeavePharmacy() },
                onDelete: profile.isPharmacyAdmin ? { viewModel.requestDeletePharmacy() } : nil
            )

            if profile.isPharmacyAdmin {
                PharmacyTeamSectionView(
                    members: viewModel.manageablePharmacists,
                    onEdit: { viewModel.didTapEditPharmacist($0) },
                    onRemove: { viewModel.requestRemovePharmacist($0) }
                )

                if let err = viewModel.removePharmacistErrorMessage {
                    inlineError(err)
                }
            }

            if let err = viewModel.leavePharmacyErrorMessage {
                inlineError(err)
            }

            if let err = viewModel.deletePharmacyErrorMessage {
                inlineError(err)
            }
        } else {
            NoPharmacyCardView()
        }
    }

    private func inlineError(_ message: String) -> some View {
        Text(message)
            .font(PharmacyColor.sans(12, .medium))
            .foregroundStyle(PharmacyColor.danger)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}
