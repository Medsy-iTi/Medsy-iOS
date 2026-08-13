//
//  MainTabBarView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import Observation
import SwiftUI

@MainActor
struct MainTabBarView: View {
    @State private var coordinator: MainTabCoordinator
    @State private var isTabBarHidden = false
    @State private var cartViewModel: CartViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var chatbotViewModel: AiChatViewModel
    @State private var requestedHomeRoute: HomeRoute?
    @State private var homeRootResetSignal = 0
    @State private var cartFeedbackTask: Task<Void, Never>?
    @State private var requestSuccessTask: Task<Void, Never>?
    @State private var isShowingRequestSuccess = false
    @State private var pendingChatbotPrompt: String?
    @State private var chatbotPromptSequence = 0
    @State private var tabBeforeChatbot: AppTab = .home
    @State private var showsProductChatbotBackButton = false
    @ObservedObject private var appSettings = AppSettings.shared
    @Environment(LanguageManager.self) private var lang

    init(coordinator: MainTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
        _cartViewModel = State(
            initialValue: DIContainer.shared.resolve(CartViewModel.self)
        )
        _profileViewModel = State(
            initialValue: DIContainer.shared.resolve(ProfileViewModel.self)
        )
        _chatbotViewModel = State(
            initialValue: DIContainer.shared.resolve(AiChatViewModel.self)
        )
    }

    var body: some View {
        TabView(selection: selectedTabBinding) {
            HomeCoordinatorView(
                requestedRoute: $requestedHomeRoute,
                rootResetSignal: $homeRootResetSignal,
                onTabBarHiddenChange: { isTabBarHidden = $0 },
                onOpenCart: { coordinator.select(.cart) },
                homeAddress: profileViewModel.displayHomeAddress,
                onOpenProfile: { coordinator.select(.profile) }
            )
            .tabItem {
                Label("tab.home".localized, systemImage: "house")
            }
            .tag(AppTab.home)

            CartCoordinatorView(
                viewModel: cartViewModel,
                onTabBarHiddenChange: { isTabBarHidden = $0 },
                onRequestCompleted: {
                    isTabBarHidden = false
                    cartViewModel.handle(.load)
                    showRequestSuccessToast()
                    homeRootResetSignal += 1
                    coordinator.select(.home)
                }
            )
            .onAppear { isTabBarHidden = false }
            .tabItem {
                Label("tab.cart".localized, systemImage: "cart")
            }
            .badge(cartViewModel.distinctProductCount)
            .tag(AppTab.cart)

            ChatbotRootView(
                viewModel: chatbotViewModel,
                onTabBarHiddenChange: { isTabBarHidden = $0 },
                onOpenCart: { coordinator.select(.cart) },
                onOpenCompleteRequest: {
                    isTabBarHidden = false
                    coordinator.select(.cart)
                },
                pendingPrompt: $pendingChatbotPrompt,
                promptSequence: chatbotPromptSequence,
                onBackToProduct: chatbotBackAction
            )
            .tabItem {
                Label("tab.medsy_ai".localized, systemImage: "sparkles")
            }
            .tag(AppTab.chatbot)

            OrdersCoordinatorView(
                onReorderCompleted: {
                    cartViewModel.handle(.load)
                },
                onGoToCart: {
                    cartViewModel.handle(.load)
                    coordinator.select(.cart)
                }
            )
            .onAppear { isTabBarHidden = false }
            .tabItem {
                Label("tab.orders".localized, systemImage: "doc.text")
            }
            .tag(AppTab.orders)

            ProfileCoordinatorView(
                onOrders: { coordinator.select(.orders) },
                onFavorites: {
                    requestedHomeRoute = .favorites
                    coordinator.select(.home)
                },
                onLogout: coordinator.logout,
                viewModel: profileViewModel
            )
            .onAppear { isTabBarHidden = false }
            .tabItem {
                Label("tab.account".localized, systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .id("\(lang.languageCode)-\(appSettings.isDarkMode)")
        .environment(\.openChatbotPrompt, { prompt in
            openChatbot(prompt: prompt)
        })
        .environment(cartViewModel)
        .tint(AppColor.green)
        .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .toolbarBackground(tabBarBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(appSettings.isDarkMode ? .dark : .light, for: .tabBar)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .onAppear(perform: configureTabBarAppearance)
        .onChange(of: appSettings.isDarkMode) { _, _ in
            configureTabBarAppearance()
        }
        .animation(.easeInOut(duration: 0.2), value: isTabBarHidden)
        .onReceive(NotificationCenter.default.publisher(for: .openChatbotTab)) { notification in
            isTabBarHidden = false
            coordinator.select(.chatbot)
            // After switching tabs, fire the auto-message about the product
            let productName = notification.userInfo?["productName"] as? String ?? ""
            let message: String
            if productName.isEmpty {
                message = "product.consult_pharmacist.default_message".localized
            } else {
                message = String(format: "product.consult_pharmacist.message".localized, productName)
            }
            Task {
                // Small delay so the tab switch animation completes first
                try? await Task.sleep(for: .milliseconds(400))
                chatbotViewModel.sendSuggestion(message)
            }
        }
        .overlay(alignment: .top) {
            if isShowingRequestSuccess {
                RequestSentBanner()
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.top, MedsySpacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else if let productName = addedProductName {
                CartAddedBanner(productName: productName)
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.top, MedsySpacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onChange(of: cartViewModel.feedbackSequence) { _, _ in
            scheduleFeedbackDismissal()
        }
        .onDisappear {
            cartFeedbackTask?.cancel()
            requestSuccessTask?.cancel()
        }
        .task {
            cartViewModel.handle(.load)
            await profileViewModel.loadProfile()
        }
        .animation(.easeInOut(duration: 0.25), value: cartViewModel.feedback)
    }

    private var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { coordinator.selectedTab },
            set: {
                isTabBarHidden = false
                showsProductChatbotBackButton = false
                coordinator.select($0)
            }
        )
    }

    private var addedProductName: String? {
        guard case let .itemAdded(productName) = cartViewModel.feedback else { return nil }
        return productName
    }

    private var chatbotBackAction: (() -> Void)? {
        guard showsProductChatbotBackButton else { return nil }
        return { returnFromChatbot() }
    }

    private func openChatbot(prompt: String) {
        if coordinator.selectedTab != .chatbot {
            tabBeforeChatbot = coordinator.selectedTab
        }
        pendingChatbotPrompt = prompt
        chatbotPromptSequence += 1
        showsProductChatbotBackButton = true
        isTabBarHidden = false
        coordinator.select(.chatbot)
    }

    private func returnFromChatbot() {
        isTabBarHidden = false
        showsProductChatbotBackButton = false
        coordinator.select(tabBeforeChatbot)
    }

    private func scheduleFeedbackDismissal() {
        cartFeedbackTask?.cancel()
        guard case .itemAdded = cartViewModel.feedback else { return }

        cartFeedbackTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            cartViewModel.handle(.dismissFeedback)
        }
    }

    private func showRequestSuccessToast() {
        requestSuccessTask?.cancel()
        withAnimation(.easeInOut(duration: 0.25)) {
            isShowingRequestSuccess = true
        }

        requestSuccessTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                isShowingRequestSuccess = false
            }
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(tabBarBackground)
        appearance.shadowColor = UIColor(tabBarBorder)

        let selectedColor = UIColor(AppColor.green)
        let normalColor = UIColor(AppColor.textSec)
        [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance]
            .forEach { itemAppearance in
                itemAppearance.selected.iconColor = selectedColor
                itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
                itemAppearance.normal.iconColor = normalColor
                itemAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
            }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private var tabBarBackground: Color {
        appSettings.isDarkMode ? Color(hex: "#0B1014") : Color(hex: "#FFFFFF")
    }

    private var tabBarBorder: Color {
        appSettings.isDarkMode ? Color(hex: "#26312C") : Color(hex: "#D9E2DC")
    }
}

private struct RequestSentBanner: View {
    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColor.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("complete_request.success.title".localized)
                    .font(MedsyFont.bodyMedium(14))
                    .foregroundStyle(AppColor.textPrim)

                Text("complete_request.success.subtitle".localized)
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "house.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.green)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.green.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
    }
}
