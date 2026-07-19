//
//  ProfileCoordinator.swift
//  Medsy-Pharmacy
//

import SwiftUI
import Observation

// MARK: - Presentations

enum PharmacyProfilePresentation: Identifiable {
    case editProfile
    case editPharmacy

    var id: String {
        switch self {
        case .editProfile: return "editProfile"
        case .editPharmacy: return "editPharmacy"
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
        }
    }

    // MARK: - ViewModel Factory

    func makeProfileViewModel() -> ProfileViewModel {
        let repo = container.resolve(ProfileRepositoryProtocol.self)
        let viewModel = ProfileViewModel(
            getProfileUseCase: GetPharmacyProfileUseCase(repository: repo),
            updateProfileUseCase: PharmacyUpdateProfileUseCase(repository: repo),
            leavePharmacyUseCase: LeavePharmacyUseCase(repository: repo),
            updatePharmacyUseCase: UpdatePharmacyUseCase(repository: repo),
            logoutUseCase: LogoutUseCase(
                repository: repo,
                tokenStore: container.resolve(TokenStoreProtocol.self)
            ),
            languageManager: container.resolve(LanguageManager.self),
            appSettings: container.resolve(PharmacyAppSettings.self)
        )
        viewModel.onNavigate = { [weak self] route in
            switch route {
            case .editProfile:
                self?.activePresentation = .editProfile
            case .editPharmacy:
                self?.activePresentation = .editPharmacy
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

// MARK: - Wrapper View (needed to capture viewModel for sheet binding)

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
