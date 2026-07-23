//
//  ProfileCoordinator.swift
//  Medsy-Pharmacy
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ProfileCoordinator: Coordinator {
	var path = NavigationPath()
	var activeSheet: ProfileSheet?

	let viewModel: ProfileViewModel

	var onLoggedOut: (() -> Void)?
	var onSessionExpired: (() -> Void)?

	init(container: PharmacyDIContainer) {
		viewModel = ProfileViewModel(
			getProfileUseCase: container.resolve(GetPharmacyProfileUseCaseProtocol.self),
			updateProfileUseCase: container.resolve(PharmacyUpdateProfileUseCaseProtocol.self),
			leavePharmacyUseCase: container.resolve(LeavePharmacyUseCaseProtocol.self),
			updatePharmacyUseCase: container.resolve(UpdatePharmacyUseCaseProtocol.self),
			deletePharmacyUseCase: container.resolve(DeletePharmacyUseCaseProtocol.self),
			removePharmacistUseCase: container.resolve(RemovePharmacistUseCaseProtocol.self),
			invitePharmacistUseCase: container.resolve(InvitePharmacistUseCaseProtocol.self),
			updatePharmacistUseCase: container.resolve(UpdatePharmacistUseCaseProtocol.self),
			logoutUseCase: container.resolve(LogoutUseCaseProtocol.self),
			languageManager: container.resolve(LanguageManager.self),
			appSettings: container.resolve(PharmacyAppSettings.self)
		)

		viewModel.onNavigate = { [weak self] route in
			self?.navigate(to: route)
		}
		viewModel.onPresentSheet = { [weak self] sheet in
			guard let self else { return }
			if case .editProfile = sheet {
				navigate(to: .personalProfileDetail)
			} else {
				activeSheet = sheet
			}
		}
		viewModel.onLoggedOut = { [weak self] in
			self?.onLoggedOut?()
		}
	}

	@ViewBuilder
	func start() -> some View {
		ProfileView(viewModel: viewModel)
	}

	func navigate(to route: ProfileRoute) {
		path.append(route)
	}

	func pop() {
		guard !path.isEmpty else { return }
		path.removeLast()
	}

	func popToRoot() {
		guard !path.isEmpty else { return }
		path.removeLast(path.count)
	}

	func showAnotherInvitation() {
		viewModel.resetInviteForm()
		if !path.isEmpty {
			path.removeLast()
		}
		path.append(ProfileRoute.invitePharmacist)
	}

	@ViewBuilder
	func destination(for route: ProfileRoute) -> some View {
		switch route {
			case .editProfile, .personalProfileDetail:
				personalProfileDestination

			case .pharmacyDetail:
				pharmacyDestination

			case .pharmacistsList:
				pharmacistsDestination

			case .invitePharmacist:
				inviteDestination

			case let .inviteSuccess(info):
				InviteSuccessView(
					info: info,
					onInviteAnother: showAnotherInvitation,
					onBack: popToRoot
				)

			case let .pharmacistProfile(member):
				PharmacistDetailView(
					member: member,
					canEdit: viewModel.canManage(member),
					canRemove: viewModel.canManage(member),
					onEdit: { self.viewModel.didTapEditPharmacist(member) },
					onRemove: { self.viewModel.requestRemovePharmacist(member) }
				)

			case .editPharmacy:
				EmptyView()

			case let .editPharmacist(member):
				PharmacistDetailView(
					member: member,
					canEdit: viewModel.canManage(member),
					canRemove: viewModel.canManage(member),
					onEdit: { self.viewModel.didTapEditPharmacist(member) },
					onRemove: { self.viewModel.requestRemovePharmacist(member) }
				)

			case .settings:
				ProfileSettingsView(viewModel: viewModel)
		}
	}

	@ViewBuilder
	func sheet(for sheet: ProfileSheet) -> some View {
		switch sheet {
			case .editProfile:
				EmptyView()

			case .editPharmacy:
				if let profile = viewModel.profile {
					EditPharmacyScreen(
						pharmacyName: profile.pharmacyName ?? "",
						pharmacyAddress: profile.pharmacyAddress ?? "",
						pharmacyPhone: profile.pharmacyPhoneNumber ?? "",
						isSaving: viewModel.isUpdatingPharmacy,
						errorMessage: viewModel.updatePharmacyErrorMessage,
						onCancel: { self.activeSheet = nil },
						onSave: { name, address, phone in
							await self.viewModel.updatePharmacy(
								name: name,
								address: address,
								phoneNumber: phone
							)
						}
					)
					.environment(viewModel.languageManager)
					.pharmacyLocalizedEnvironment()
				}

			case let .editPharmacist(member):
				EditPharmacistScreen(
					member: member,
					isSaving: viewModel.isUpdatingPharmacist,
					errorMessage: viewModel.updatePharmacistErrorMessage,
					onCancel: { self.activeSheet = nil },
					onSave: { email, firstName, lastName, homeAddress, dateOfBirth in
						await self.viewModel.updatePharmacist(
							id: member.id,
							email: email,
							firstName: firstName,
							lastName: lastName,
							homeAddress: homeAddress,
							dateOfBirth: dateOfBirth
						)
					}
				)
				.environment(viewModel.languageManager)
				.pharmacyLocalizedEnvironment()

			case let .pharmacistOptions(member):
				PharmacistOptionsSheet(
					member: member,
					onViewProfile: { [weak self] in
						self?.activeSheet = nil
						self?.navigate(to: .pharmacistProfile(member))
					},
					onRemove: { [weak self] in
						self?.activeSheet = nil
						self?.viewModel.requestRemovePharmacist(member)
					}
				)
				.presentationDetents([.height(280)])
				.presentationDragIndicator(.visible)

			case let .removePharmacist(member):
				RemovePharmacistView(
					member: member,
					isRemoving: viewModel.isRemovingPharmacist,
					errorMessage: viewModel.removePharmacistErrorMessage,
					onCancel: { self.activeSheet = nil },
					onRemove: { await self.viewModel.confirmRemovePharmacist() }
				)
				.environment(viewModel.languageManager)
				.pharmacyLocalizedEnvironment()
		}
	}

	@ViewBuilder
	private var personalProfileDestination: some View {
		if let profile = viewModel.profile {
			PharmacyEditProfileScreen(
				firstName: profile.firstName,
				lastName: profile.lastName,
				homeAddress: profile.homeAddress ?? "",
				dateOfBirth: profile.dateOfBirth,
				isSaving: viewModel.isSaving,
				errorMessage: viewModel.saveErrorMessage,
				onCancel: pop,
				onSave: { homeAddress, dateOfBirth in
					await self.viewModel.updateProfile(
						homeAddress: homeAddress,
						dateOfBirth: dateOfBirth
					)
				}
			)
		}
	}

	@ViewBuilder
	private var pharmacyDestination: some View {
		if let profile = viewModel.profile, profile.pharmacyId != nil {
			PharmacyDetailView(
				pharmacy: profile.toPharmacySummary(),
				isAdmin: profile.isPharmacyAdmin,
				isDeleting: viewModel.isDeletingPharmacy,
				isLeaving: viewModel.isLeavingPharmacy,
				deleteErrorMessage: viewModel.deletePharmacyErrorMessage,
				leaveErrorMessage: viewModel.leavePharmacyErrorMessage,
				onEdit: viewModel.didTapEditPharmacy,
				onDelete: {
					Task { await self.viewModel.confirmDeletePharmacy() }
				},
				onLeave: {
					Task { await self.viewModel.confirmLeavePharmacy() }
				},
				onDismissError: {}
			)
		}
	}

	private var pharmacistsDestination: some View {
		PharmacistsListView(
			members: viewModel.pharmacyMembers,
			isAdmin: viewModel.profile?.isPharmacyAdmin == true,
			isInviting: viewModel.isInvitingPharmacist,
			inviteErrorMessage: viewModel.inviteErrorMessage,
			onInvite: viewModel.didTapInvitePharmacist,
			onDismissError: viewModel.resetInviteForm,
			onMemberTap: { [weak self] member in
				guard let self else { return }
				if viewModel.canManage(member) {
					viewModel.didTapPharmacistOptions(member)
				} else {
					viewModel.didTapViewPharmacistProfile(member)
				}
			}
		)
	}

	@ViewBuilder
	private var inviteDestination: some View {
		if let pharmacyName = viewModel.profile?.pharmacyName {
			InvitePharmacistView(
				pharmacyName: pharmacyName,
				isInviting: viewModel.isInvitingPharmacist,
				errorMessage: viewModel.inviteErrorMessage,
				onInvite: { [weak self] email in
					guard let self else { return false }
					viewModel.inviteEmail = email
					return await viewModel.sendInvitation()
				}
			)
		}
	}
}

private struct PharmacistOptionsSheet: View {
	let member: PharmacistMember
	let onViewProfile: () -> Void
	let onRemove: () -> Void

	var body: some View {
		VStack(spacing: PharmacySpacing.md) {
			HStack(spacing: PharmacySpacing.sm) {
				PharmacistAvatarView(pharmacist: member.toPharmacist(), diameter: 56)

				VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
					Text(member.fullName)
						.font(.headline)
						.foregroundStyle(PharmacyColor.textPrimary)
					Text("profile.role_pharmacist".localized)
						.font(.subheadline)
						.foregroundStyle(PharmacyColor.primary)
				}

				Spacer()
			}

			ProfileSectionContainer {
				ProfileNavigationRow(
					icon: "person",
					title: "pharmacy_team.view_profile".localized,
					action: onViewProfile
				)

				ProfileRowDivider()

				ProfileNavigationRow(
					icon: "trash",
					iconTint: PharmacyColor.danger,
					title: "pharmacy_team.remove".localized,
					action: onRemove
				)
			}
		}
		.padding(PharmacySpacing.md)
		.background(PharmacyColor.bg.ignoresSafeArea())
	}
}

private struct ProfileSettingsView: View {
	@Bindable var viewModel: ProfileViewModel
	@ObservedObject private var appSettings = PharmacyAppSettings.shared
	@Environment(LanguageManager.self) private var languageManager

	var body: some View {
		Form {
			Section("language_title".localized) {
				Picker("language_title".localized, selection: languageBinding) {
					Text("english".localized).tag(PharmacyAppLanguage.english)
					Text("arabic".localized).tag(PharmacyAppLanguage.arabic)
				}
				.pickerStyle(.inline)
			}

			Section("theme_title".localized) {
				Picker("theme_title".localized, selection: themeBinding) {
					Text("theme_light".localized).tag(false)
					Text("theme_dark".localized).tag(true)
				}
				.pickerStyle(.inline)
			}
		}
		.scrollContentBackground(.hidden)
		.background(PharmacyColor.bg)
		.navigationTitle("settings_title".localized)
		.navigationBarTitleDisplayMode(.inline)
	}

	private var languageBinding: Binding<PharmacyAppLanguage> {
		Binding(
			get: { languageManager.currentLanguage },
			set: viewModel.setLanguage
		)
	}

	private var themeBinding: Binding<Bool> {
		Binding(
			get: { appSettings.isDarkMode },
			set: viewModel.setTheme
		)
	}
}
