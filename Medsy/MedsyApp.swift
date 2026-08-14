//
//  MedsyApp.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import StripePaymentSheet
import SwiftUI
import SwiftData
import UserNotifications

@main
struct MedsyApp: App {

    private let languageManager: LanguageManager
    private let onboardingFactory: OnboardingFactory
    private let authenticationFactory: AuthenticationFactory
    private let logoutUseCase: LogoutUseCaseProtocol
    private let appCoordinator: AppCoordinator
    private let reminderContainer: ModelContainer
    private let reminderStore: ReminderStore

    init() {
        // Build the SwiftData container for medication reminders
        let schema = Schema([MedReminder.self])
        let container = (try? SwiftDataFactory.shared.makeContainer(
            for: schema,
            configuration: .persistent(name: "MedsyReminders")
        )) ?? (try! ModelContainer(for: schema))
        reminderContainer = container
        reminderStore = ReminderStore(context: container.mainContext)

        AppAssembler.shared.assemble(modules: [
            CoreAssembly(),
            OnboardingAssembly(),
            AuthenticationAssembly(),
            CategoriesAssembly(),
            ProductsAssembly(),
            ProductsAssembly(),
            ProductDetailAssembly(),
            FavoritesAssembly(),
            ProductsFeatureAssembly(),
            CartAssembly(),
            ProfileAssembly(),
            CompleteRequestAssembly(),
            PharmacyProfileAssembly(),
            OrdersAssembly(),
            PresenceAssembly(),
            ChatbotAssembly(reminderStore: reminderStore),
            PrescriptionAssembly(),
            MedicineAnalyzeAssembly(),
            OffersAssembly(),
            PaymentAssembly()
        ])

        languageManager = AppAssembler.shared.container.resolve(LanguageManager.self)
        onboardingFactory = AppAssembler.shared.container.resolve(OnboardingFactory.self)
        authenticationFactory = AppAssembler.shared.container.resolve(AuthenticationFactory.self)
        logoutUseCase = AppAssembler.shared.container.resolve(LogoutUseCaseProtocol.self)
      
//        heartbeatService = AppAssembler.shared.container.resolve(HeartbeatService.self)
        appCoordinator = AppCoordinator(
            shouldShowOnboarding: onboardingFactory.shouldShow(),
            authenticationStatusStore: AppAssembler.shared.container.resolve(UserDefaultsStatusStoreProtocol.self),
            logoutUseCase: logoutUseCase
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                onboardingFactory: onboardingFactory,
                authenticationFactory: authenticationFactory,
                coordinator: appCoordinator
            )
//            .task {
//                heartbeatService.startHeartbeat()
//                print("[MedsyApp] 🚀 Customer App launched — heartbeat started")
//            }
                     .localizedEnvironment()
            .environment(languageManager)
            .modelContainer(reminderContainer)
            .onOpenURL { url in
                _ = StripeAPI.handleURLCallback(with: url)
            }
            .task {
                // Reboot recovery: reschedule any active reminders whose
                // UNNotification requests were cleared by a device restart.
                await ReminderScheduler.shared.rescheduleActive(from: reminderStore)
            }
        }
    }
}
