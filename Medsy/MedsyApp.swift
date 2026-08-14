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

extension Notification.Name {
    /// Posted when the user taps a medication reminder push notification.
    /// MainTabBarView listens for this to navigate to My Reminders.
    static let openRemindersTab = Notification.Name("medsy.openRemindersTab")
}

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

        appCoordinator = AppCoordinator(
            shouldShowOnboarding: onboardingFactory.shouldShow(),
            authenticationStatusStore: AppAssembler.shared.container.resolve(UserDefaultsStatusStoreProtocol.self),
            logoutUseCase: logoutUseCase
        )

        // Register self as the notification delegate so foreground banners are shown
        // and notification taps navigate to My Reminders.
        UNUserNotificationCenter.current().delegate = AppNotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                onboardingFactory: onboardingFactory,
                authenticationFactory: authenticationFactory,
                coordinator: appCoordinator
            )
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

// MARK: - Notification Delegate

/// Singleton delegate that handles foreground notification presentation
/// and notification tap navigation.
final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = AppNotificationDelegate()
    private override init() {}

    /// Show the notification banner even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// When the user taps the notification, navigate to the Reminders screen.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        let categoryID  = response.notification.request.content.categoryIdentifier
        if categoryID == "MEDICATION_REMINDER" || identifier.hasPrefix("medsy.reminder.") {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .openRemindersTab, object: nil)
            }
        }
        completionHandler()
    }
}

