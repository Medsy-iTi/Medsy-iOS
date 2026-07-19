//
//  ProfileCoordinator.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI
import Observation

@Observable
@MainActor
final class ProfileCoordinator: Coordinator {
    var path = NavigationPath()

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
    }

    private func makeProfileViewModel() -> ProfileViewModel {
        let viewModel = ProfileViewModel(
            getProfileUseCase: GetPharmacyProfileUseCase(repository: container.resolve(ProfileRepositoryProtocol.self)),
            logoutUseCase: LogoutUseCase(
                repository: container.resolve(ProfileRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            ),
            languageManager: container.resolve(LanguageManager.self),
            appSettings: container.resolve(PharmacyAppSettings.self)
        )
        viewModel.onNavigate = { [weak self] route in self?.navigate(to: route) }
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
        case .changePhoneNumber:
            PlaceholderDestinationView(titleKey: "change_phone_title")
        case .license:
            PlaceholderDestinationView(titleKey: "license_title")
        case .registeredLocation:
            PlaceholderDestinationView(titleKey: "registered_location_title")
        case .editDataRequest:
            PlaceholderDestinationView(titleKey: "edit_data_request_title")
        case .languageSelection:
            LanguageSelectionView(languageManager: container.resolve(LanguageManager.self))
        case .themeSelection:
            ThemeSelectionView(appSettings: container.resolve(PharmacyAppSettings.self))
        }
    }
}
