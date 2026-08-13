//
//  ProfileCoordinatorView.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

struct ProfileCoordinatorView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var coordinator: ProfileCoordinator

    let onOrders: () -> Void
    let onTabBarHiddenChange: (Bool) -> Void

    init(
        onOrders: @escaping () -> Void,
        onLogout: @escaping () -> Void,
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in },
        viewModel: ProfileViewModel = DIContainer.shared.resolve(ProfileViewModel.self)
    ) {
        self.onOrders = onOrders
        self.onTabBarHiddenChange = onTabBarHiddenChange
        _coordinator = State(initialValue: ProfileCoordinator(viewModel: viewModel, onLogout: onLogout))
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            ProfileScreen(
                patientName: coordinator.patientName,
                phoneNumber: coordinator.phoneNumber,
                email: coordinator.email,
                homeAddress: coordinator.displayHomeAddress,
                dateOfBirthText: coordinator.displayDateOfBirth,
                hasDeliveryLocation: coordinator.hasDeliveryLocation,
                state: coordinator.state,
                onRetry: { Task { await coordinator.refreshProfile() } },
                onEditProfile: { coordinator.showEditProfile() },
                onAddDeliveryLocation: { coordinator.showEditProfile(openAddressPicker: true) },
                onLanguage: coordinator.showLanguagePicker,
                onTheme: coordinator.showThemePicker,
                onOrders: onOrders,
                onFavorites: coordinator.showFavorites,
                onHowMedsyWorks: coordinator.showHowMedsyWorks,
                onHelpCenter: coordinator.showHelpCenter,
                onReportProblem: coordinator.showReportProblem,
                onLogout: coordinator.requestLogout
            )
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .favorites:
                    FavoriteView(
                        onBack: coordinator.goBack,
                        onBrowse: { coordinator.showSearch() },
                        onSelectMedicine: { productID in
                            coordinator.path.append(ProductDetailDestination(productId: productID))
                        }
                    )
                case .search(let query):
                    SearchCoordinatorView(
                        query: query,
                        onBack: coordinator.goBack,
                        onPush: { destination in
                            coordinator.path.append(destination)
                        }
                    )
                case .howMedsyWorks:
                    HowMedsyWorksView(onBack: coordinator.goBack)
                case .helpCenter:
                    ProfileHelpCenterView(onBack: coordinator.goBack)
                case .reportProblem:
                    ReportProblemView(onBack: coordinator.goBack)
                }
            }
            .navigationDestination(for: ProductDetailDestination.self) { destination in
                ProductDetailView(productId: destination.productId)
            }
        }
        .task {
            await coordinator.loadProfile()
        }
        .refreshable {
            await coordinator.refreshProfile()
        }
        .sheet(item: $coordinator.activePresentation) { presentation in
            sheet(for: presentation, coordinator: coordinator)
        }
        .alert("profile.logout.title".localized, isPresented: $coordinator.showsLogoutConfirmation) {
            Button("common.cancel".localized, role: .cancel) { coordinator.cancelLogout() }
            Button("profile.logout".localized, role: .destructive) { coordinator.confirmLogout() }
        } message: {
            Text("profile.logout.message".localized)
        }
        .onAppear {
            onTabBarHiddenChange(!coordinator.path.isEmpty)
        }
        .onChange(of: coordinator.path.isEmpty) { _, isEmpty in
            onTabBarHiddenChange(!isEmpty)
        }
    }

    @ViewBuilder
    private func sheet(for presentation: ProfilePresentation, coordinator: ProfileCoordinator) -> some View {
        switch presentation {
        case .editProfile(let openAddressPicker):
            NavigationStack {
                EditProfileScreen(
                    firstName: coordinator.firstName,
                    lastName: coordinator.lastName,
                    phoneNumber: coordinator.phoneNumber,
                    email: coordinator.email,
                    homeAddress: coordinator.homeAddress,
                    latitude: coordinator.homeLatitude,
                    longitude: coordinator.homeLongitude,
                    dateOfBirth: coordinator.dateOfBirth,
                    opensAddressPickerOnAppear: openAddressPicker,
                    isSaving: coordinator.isSaving,
                    errorMessage: coordinator.saveErrorMessage,
                    onCancel: coordinator.dismissPresentation,
                    onSave: coordinator.updateProfile
                )
            }
            .environment(languageManager)
            .localizedEnvironment()
        case .language:
            ProfileSelectionSheet(
                titleKey: "profile.language.title",
                messageKey: "profile.language.message",
                options: languageOptions,
                onSelect: { option in
                    if let language = AppLanguage(rawValue: option.id) {
                        withAnimation(.easeInOut(duration: 0.3)) { languageManager.set(language) }
                    }
                    coordinator.dismissPresentation()
                }
            )
            .environment(languageManager)
            .presentationDetents([.height(308)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
        case .theme:
            ProfileSelectionSheet(
                titleKey: "profile.theme.title",
                messageKey: "profile.theme.message",
                options: themeOptions,
                onSelect: { option in
                    withAnimation(.easeInOut(duration: 0.25)) { appSettings.isDarkMode = option.id == "dark" }
                    coordinator.dismissPresentation()
                }
            )
            .environment(languageManager)
            .presentationDetents([.height(308)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
        }
    }

    private var languageOptions: [ProfileSelectionOption] {
        [
            ProfileSelectionOption(id: AppLanguage.arabic.rawValue, titleKey: "language.arabic", subtitleKey: "profile.language.arabic.subtitle", iconName: "textformat", iconColor: ProfileStyle.green, isSelected: languageManager.currentLanguage == .arabic),
            ProfileSelectionOption(id: AppLanguage.english.rawValue, titleKey: "language.english", subtitleKey: "profile.language.english.subtitle", iconName: "character.book.closed", iconColor: Color(hex: "#38BDF8"), isSelected: languageManager.currentLanguage == .english)
        ]
    }

    private var themeOptions: [ProfileSelectionOption] {
        [
            ProfileSelectionOption(id: "light", titleKey: "profile.theme.light", subtitleKey: "profile.theme.light.subtitle", iconName: "sun.max", iconColor: Color(hex: "#F59E0B"), isSelected: !appSettings.isDarkMode),
            ProfileSelectionOption(id: "dark", titleKey: "profile.theme.dark", subtitleKey: "profile.theme.dark.subtitle", iconName: "moon", iconColor: Color(hex: "#A855F7"), isSelected: appSettings.isDarkMode)
        ]
    }
}
