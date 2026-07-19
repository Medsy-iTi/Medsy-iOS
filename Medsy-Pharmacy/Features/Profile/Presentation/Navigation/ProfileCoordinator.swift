//
//  ProfileCoordinator.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI
import Observation

enum PharmacyProfilePresentation: Identifiable {
    case editProfile

    var id: String {
        switch self {
        case .editProfile: return "editProfile"
        }
    }
}

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



    @ViewBuilder
    func start() -> some View {
        let viewModel = makeProfileViewModel()
        ProfileView(viewModel: viewModel)
            .sheet(item: Binding(
                get: { self.activePresentation },
                set: { self.activePresentation = $0 }
            )) { presentation in
				self.sheet(for: presentation, viewModel: viewModel)
            }
    }

    @ViewBuilder
    private func sheet(for presentation: PharmacyProfilePresentation, viewModel: ProfileViewModel) -> some View {
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
                        let success = await viewModel.updateProfile(homeAddress: homeAddress, dateOfBirth: dateOfBirth)
                        return success
                    }
                )

            }
        }
    }

    private func makeProfileViewModel() -> ProfileViewModel {
        let viewModel = ProfileViewModel(
            getProfileUseCase: GetPharmacyProfileUseCase(repository: container.resolve(ProfileRepositoryProtocol.self)),
            updateProfileUseCase: PharmacyUpdateProfileUseCase(repository: container.resolve(ProfileRepositoryProtocol.self)),
            logoutUseCase: LogoutUseCase(
                repository: container.resolve(ProfileRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            ),
            languageManager: container.resolve(LanguageManager.self),
            appSettings: container.resolve(PharmacyAppSettings.self)
        )
        viewModel.onNavigate = { [weak self] route in
            if route == .editProfile {
                self?.activePresentation = .editProfile
            } else {
                self?.navigate(to: route)
            }
        }
        viewModel.onLoggedOut = { [weak self] in self?.onLoggedOut?() }
        return viewModel
    }



    func navigate(to route: ProfileRoute) {
        path.append(route)
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
        switch route {
        case .settings:
            PlaceholderDestinationView(titleKey: "settings_title")
        case .pharmacyDetails:
            PlaceholderDestinationView(titleKey: "pharmacy_details_title")

			case .editProfile:
				PlaceholderDestinationView(titleKey: "")
		}
    }
}
