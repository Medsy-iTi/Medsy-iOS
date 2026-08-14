//
//  MainTabBarView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import Observation
import SwiftUI
import UIKit

@MainActor
struct MainTabBarView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var coordinator: MainTabCoordinator
    @State private var isTabBarHidden = false
    @State private var cartViewModel: CartViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var chatbotViewModel: AiChatViewModel
    @State private var requestedHomeRoute: HomeRoute?
    @State private var requestedOrderID: Int?
    @State private var homeRootResetSignal = 0
    @State private var cartFeedbackTask: Task<Void, Never>?
    @State private var requestSuccessTask: Task<Void, Never>?
    @State private var isShowingRequestSuccess = false
    @State private var pendingChatbotPrompt: String?
    @State private var chatbotPromptSequence = 0
    @State private var tabBeforeChatbot: AppTab = .home
    @State private var showsProductChatbotBackButton = false
    @ObservedObject private var appSettings = AppSettings.shared

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
                onOpenProfile: { coordinator.select(.profile) },
                onPaymentCompleted: showPaidOrder
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
                requestedOrderID: $requestedOrderID,
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
                onLogout: coordinator.logout,
                onTabBarHiddenChange: { isTabBarHidden = $0 },
                viewModel: profileViewModel
            )
            .onAppear { isTabBarHidden = false }
            .tabItem {
                Label("tab.account".localized, systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .environment(\.openChatbotPrompt, { prompt in
            openChatbot(prompt: prompt)
        })
        .environment(cartViewModel)
        .tint(AppColor.green)
        .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .preferredColorScheme(appSettings.preferredColorScheme)
        .onAppear(perform: configureTabBarAppearance)
        .onChange(of: appSettings.isDarkMode) { _, _ in
            configureTabBarAppearance()
        }
        .onChange(of: languageManager.currentLanguage) { _, _ in
            configureTabBarAppearance()
        }
        .onChange(of: coordinator.selectedTab) { _, selectedTab in
            refreshCartIfNeeded(for: selectedTab)
        }
        .task(id: coordinator.selectedTab) {
            await refreshTabBarAppearanceAfterTransition()
        }
        .task(id: isTabBarHidden) {
            await refreshTabBarAppearanceAfterTransition()
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
        .background(
            TabBarAppearanceUpdater(
                palette: tabBarPalette
            )
            .frame(width: 0, height: 0)
        )
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

    private func showPaidOrder(masterOrderID: Int) {
        isTabBarHidden = false
        homeRootResetSignal += 1
        requestedOrderID = masterOrderID
        coordinator.select(.orders)
    }

    private func refreshCartIfNeeded(for selectedTab: AppTab) {
        guard selectedTab == .cart else { return }
        cartViewModel.handle(.load)
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
        TabBarAppearanceUpdater.apply(palette: tabBarPalette)
    }

    private func refreshTabBarAppearanceAfterTransition() async {
        await Task.yield()
        configureTabBarAppearance()
    }

    private var tabBarPalette: TabBarPalette {
        TabBarPalette(
            isDarkMode: appSettings.isDarkMode,
            isRTL: languageManager.isRTL
        )
    }
}

private struct TabBarPalette {
    let backgroundColor: UIColor
    let borderColor: UIColor
    let selectedColor: UIColor
    let normalColor: UIColor
    let semanticContentAttribute: UISemanticContentAttribute

    init(isDarkMode: Bool, isRTL: Bool) {
        backgroundColor = UIColor(isDarkMode ? AppColor.background : AppColor.surface)
        borderColor = UIColor(AppColor.border)
        selectedColor = UIColor(AppColor.green)
        normalColor = UIColor(AppColor.textSec)
        semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    }
}

private struct TabBarAppearanceUpdater: UIViewControllerRepresentable {
    let palette: TabBarPalette

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        Self.apply(palette: palette)
    }

    static func apply(palette: TabBarPalette) {
        let appearance = UITabBarAppearance.medsyAppearance(palette: palette)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().backgroundColor = palette.backgroundColor
        UITabBar.appearance().barTintColor = palette.backgroundColor
        UITabBar.appearance().tintColor = palette.selectedColor
        UITabBar.appearance().unselectedItemTintColor = palette.normalColor
        UITabBar.appearance().semanticContentAttribute = palette.semanticContentAttribute

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { window in
                apply(appearance: appearance, palette: palette, to: window.rootViewController)
            }
    }

    private static func apply(
        appearance: UITabBarAppearance,
        palette: TabBarPalette,
        to viewController: UIViewController?
    ) {
        guard let viewController else { return }

        if let tabBarController = viewController as? UITabBarController {
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
            tabBarController.tabBar.backgroundColor = palette.backgroundColor
            tabBarController.tabBar.barTintColor = palette.backgroundColor
            tabBarController.tabBar.tintColor = palette.selectedColor
            tabBarController.tabBar.unselectedItemTintColor = palette.normalColor
            tabBarController.tabBar.semanticContentAttribute = palette.semanticContentAttribute
            tabBarController.tabBar.setNeedsLayout()
            tabBarController.tabBar.layoutIfNeeded()
        }

        viewController.children.forEach {
            apply(appearance: appearance, palette: palette, to: $0)
        }

        if let presentedViewController = viewController.presentedViewController {
            apply(appearance: appearance, palette: palette, to: presentedViewController)
        }
    }
}

private extension UITabBarAppearance {
    static func medsyAppearance(palette: TabBarPalette) -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = palette.backgroundColor
        appearance.shadowColor = palette.borderColor

        [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance]
            .forEach { itemAppearance in
                itemAppearance.selected.iconColor = palette.selectedColor
                itemAppearance.selected.titleTextAttributes = [.foregroundColor: palette.selectedColor]
                itemAppearance.normal.iconColor = palette.normalColor
                itemAppearance.normal.titleTextAttributes = [.foregroundColor: palette.normalColor]
            }

        return appearance
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
