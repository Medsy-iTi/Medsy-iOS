//
//  ProfileView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel

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
                Button {
                    viewModel.didTapSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(PharmacyColor.textPrimary)
                }
                .accessibilityLabel("settings_title".localized)
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
            PharmacyInfoCardView(profile: profile) {
                viewModel.didTapPharmacyCard()
            }

            ProfileSectionContainer {
                ProfileValueRow(
                    icon: "phone.fill",
                    title: "phone_number_title".localized,
                    value: profile.phoneNumber,
                    actionTitle: "change_action".localized,
                    action: viewModel.didTapChangePhoneNumber
                )
            }

            ProfileSectionContainer {
                ProfileNavigationRow(
                    icon: "doc.text.fill",
                    title: "license_title".localized,
                    subtitle: profile.licenseSummary,
                    action: viewModel.didTapLicense
                )
                ProfileRowDivider()
                ProfileNavigationRow(
                    icon: "mappin.circle.fill",
                    title: "registered_location_title".localized,
                    subtitle: profile.registeredAddress,
                    action: viewModel.didTapRegisteredLocation
                )
                ProfileRowDivider()
                ProfileNavigationRow(
                    icon: "square.and.pencil",
                    title: "edit_data_request_title".localized,
                    subtitle: "edit_data_request_subtitle".localized,
                    action: viewModel.didTapEditDataRequest
                )
            }

            ProfileSectionContainer {
                ProfileToggleRow(
                    icon: "clock.badge.checkmark.fill",
                    title: "order_receiving_status_title".localized,
                    badgeText: viewModel.orderStatusBadgeText,
                    isLoading: viewModel.isTogglingStatus,
                    isOn: Binding(
                        get: { viewModel.isAcceptingOrders },
                        set: { viewModel.toggleOrderReceivingStatus(to: $0) }
                    )
                )
            }

            ProfileSectionContainer {
                ProfileNavigationRow(
                    icon: "globe",
                    title: "language_title".localized,
                    subtitle: viewModel.languageDisplayName,
                    action: viewModel.didTapLanguage
                )
                ProfileRowDivider()
                ProfileNavigationRow(
                    icon: "moon.stars.fill",
                    iconTint: PharmacyColor.secondary,
                    title: "theme_title".localized,
                    subtitle: viewModel.themeDisplayName,
                    action: viewModel.didTapTheme
                )
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

