//
//  ProfileCoordinator.swift
//  Medsy-Pharmacy
//

import SwiftUI
import Observation



enum PharmacyProfilePresentation: Identifiable {
    case editProfile
    case editPharmacy
    case editPharmacist(PharmacistMember)
    case invitePharmacist
    case removePharmacist(PharmacistMember)

    var id: String {
        switch self {
        case .editProfile: return "editProfile"
        case .editPharmacy: return "editPharmacy"
        case let .editPharmacist(member): return "editPharmacist-\(member.id)"
        case .invitePharmacist: return "invitePharmacist"
        case let .removePharmacist(member): return "removePharmacist-\(member.id)"
        }
    }
}

// MARK: - Coordinator

@Observable
@MainActor
final class ProfileCoordinator: Coordinator {
    var path = NavigationPath()
    var activePresentation: PharmacyProfilePresentation?

    private let container: PharmacyDIContainer

    var onLoggedOut: (() -> Void)?
    var onSessionExpired: (() -> Void)?

    init(container: PharmacyDIContainer) {
        self.container = container
    }

    // MARK: - Start

    @ViewBuilder
    func start() -> some View {
        let viewModel = makeProfileViewModel()
        NavigationView(viewModel: viewModel, coordinator: self)
    }

    // MARK: - Sheets

    @ViewBuilder
    func sheet(for presentation: PharmacyProfilePresentation, viewModel: ProfileViewModel) -> some View {
        switch presentation {

        case .editProfile:
            if let profile = viewModel.profile {
                PharmacyEditProfileScreen(
                    name: profile.fullName,
                    phoneNumber: profile.phoneNumber,
                    email: profile.email,
                    homeAddress: profile.homeAddress ?? "",
                    dateOfBirth: profile.dateOfBirth,
                    isSaving: viewModel.isSaving,
                    errorMessage: viewModel.saveErrorMessage,
                    onCancel: { self.activePresentation = nil },
                    onSave: { homeAddress, dateOfBirth in
                        await viewModel.updateProfile(homeAddress: homeAddress, dateOfBirth: dateOfBirth)
                    }
                )
                .environment(viewModel.languageManager)
                .pharmacyLocalizedEnvironment()
            }

        case .editPharmacy:
            if let profile = viewModel.profile {
                EditPharmacyScreen(
                    pharmacyName: profile.pharmacyName ?? "",
                    pharmacyAddress: profile.pharmacyAddress ?? "",
                    pharmacyPhone: profile.pharmacyPhoneNumber ?? "",
                    isSaving: viewModel.isUpdatingPharmacy,
                    errorMessage: viewModel.updatePharmacyErrorMessage,
                    onCancel: { self.activePresentation = nil },
                    onSave: { name, address, phone in
                        await viewModel.updatePharmacy(name: name, address: address, phoneNumber: phone)
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
                onCancel: { self.activePresentation = nil },
                onSave: { email, firstName, lastName, homeAddress, dateOfBirth in
                    await viewModel.updatePharmacist(
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

        case .invitePharmacist:
            if let profile = viewModel.profile, let pharmacyName = profile.pharmacyName {
                InvitePharmacistView(
                    pharmacyName: pharmacyName,
                    isInviting: viewModel.isInvitingPharmacist,
                    errorMessage: viewModel.inviteErrorMessage,
                    onCancel: { 
                        self.activePresentation = nil
                        viewModel.resetInviteForm()
                    },
                    onInvite: { email in
                        viewModel.inviteEmail = email
                        let success = await viewModel.sendInvitation()
                        if success {
                            self.activePresentation = nil
                        }
                        return success
                    }
                )
                .environment(viewModel.languageManager)
                .pharmacyLocalizedEnvironment()
            }

        case let .removePharmacist(member):
            RemovePharmacistView(
                member: member,
                isRemoving: viewModel.isRemovingPharmacist,
                errorMessage: viewModel.removePharmacistErrorMessage,
                onCancel: { self.activePresentation = nil },
                onRemove: {
                    await viewModel.confirmRemovePharmacist()
                }
            )
            .environment(viewModel.languageManager)
            .pharmacyLocalizedEnvironment()
        }
    }



    func makeProfileViewModel() -> ProfileViewModel {
        let viewModel = ProfileViewModel(
            getProfileUseCase: container.resolve(GetPharmacyProfileUseCaseProtocol.self),
            updateProfileUseCase: container.resolve(PharmacyUpdateProfileUseCaseProtocol.self),
            leavePharmacyUseCase: container.resolve(LeavePharmacyUseCaseProtocol.self),
            updatePharmacyUseCase: container.resolve(UpdatePharmacyUseCaseProtocol.self),
            deletePharmacyUseCase: container.resolve(DeletePharmacyUseCaseProtocol.self),
            removePharmacistUseCase: container.resolve(RemovePharmacistUseCaseProtocol.self),
            invitePharmacistUseCase: container.resolve(InvitePharmacistUseCaseProtocol.self),
            updatePharmacistUseCase: container.resolve(UpdatePharmacistUseCaseProtocol.self),
            logoutUseCase: container.resolve(LogoutUseCaseProtocol.self),
            goOnDutyUseCase: container.resolve(GoOnDutyUseCaseProtocol.self),
            goOffDutyUseCase: container.resolve(GoOffDutyUseCaseProtocol.self),
            heartbeatService: container.resolve(PharmacyHeartbeatService.self),
            dutyStatusStore: container.resolve(DutyStatusStore.self),
            languageManager: container.resolve(LanguageManager.self),
            appSettings: container.resolve(PharmacyAppSettings.self)
        )
        viewModel.onNavigate = { [weak self] route in
            switch route {
            case .editProfile:
                self?.activePresentation = .editProfile
            case .editPharmacy:
                self?.activePresentation = .editPharmacy
            case let .editPharmacist(member):
                self?.activePresentation = .editPharmacist(member)
            case .invitePharmacist:
                self?.activePresentation = .invitePharmacist
            default:
                break
            }
        }
        viewModel.onPresentSheet = { [weak self] sheet in
            switch sheet {
            case .editProfile:
                self?.activePresentation = .editProfile
            case .editPharmacy:
                self?.activePresentation = .editPharmacy
            case let .editPharmacist(member):
                self?.activePresentation = .editPharmacist(member)
            case let .removePharmacist(member):
                self?.activePresentation = .removePharmacist(member)
            default:
                break
            }
        }
        viewModel.onLoggedOut = { [weak self] in self?.onLoggedOut?() }
        return viewModel
    }

    // MARK: - Navigation

    func navigate(to route: ProfileRoute) {
        // All routes handled as sheets
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    @ViewBuilder
    func destination(for route: ProfileRoute) -> some View {
        EmptyView()
    }
}



private struct NavigationView: View {
    @State var viewModel: ProfileViewModel
    let coordinator: ProfileCoordinator

    var body: some View {
        ProfileView(viewModel: viewModel)
            .sheet(item: Binding(
                get: { coordinator.activePresentation },
                set: { coordinator.activePresentation = $0 }
            )) { presentation in
                coordinator.sheet(for: presentation, viewModel: viewModel)
            }
    }
}
