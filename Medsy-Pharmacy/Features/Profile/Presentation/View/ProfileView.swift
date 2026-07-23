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
		.profileConfirmationDialogs(viewModel: viewModel)
		.overlay {
			if isPerformingBlockingAction {
				ProfileBlockingProgressOverlay()
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
		VStack(alignment: .leading, spacing: PharmacySpacing.md) {
			ProfileSummaryCard(
				profile: profile,
				onTap: viewModel.didTapPersonalProfile
			)

			ProfilePharmacySection(
				profile: profile,
				pharmacistCountLabel: viewModel.pharmacistCountLabel,
				errorMessages: pharmacyErrorMessages,
				onPharmacyTap: viewModel.didTapPharmacyProfile,
				onPharmacistsTap: viewModel.didTapPharmacistsList,
				onInviteTap: viewModel.didTapInvitePharmacist
			)

			ProfilePreferencesSection(
				currentLanguage: languageManager.currentLanguage,
				isDarkMode: appSettings.isDarkMode,
				onLanguageChange: viewModel.setLanguage,
				onThemeChange: viewModel.setTheme
			)

			ProfileAccountActionsSection(
				onEditProfile: viewModel.didTapPersonalProfile,
				onLogout: viewModel.requestLogout
			)
		}
	}

	private var pharmacyErrorMessages: [String] {
		[
			viewModel.removePharmacistErrorMessage,
			viewModel.leavePharmacyErrorMessage,
			viewModel.deletePharmacyErrorMessage
		].compactMap { $0 }
	}

	private var isPerformingBlockingAction: Bool {
		viewModel.isLoggingOut
		|| viewModel.isLeavingPharmacy
		|| viewModel.isDeletingPharmacy
	}
}
