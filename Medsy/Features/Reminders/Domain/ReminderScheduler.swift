//
//  ReminderScheduler.swift
//  Medsy
//


import Foundation
@preconcurrency import UserNotifications

final class ReminderScheduler: Sendable {

    static let shared = ReminderScheduler()
    private let center = UNUserNotificationCenter.current()
    private let notificationCategoryID = "MEDICATION_REMINDER"

    private init() {}


    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }


    func schedule(reminder: MedReminder) async {
        guard await requestAuthorization() else { return }

        let maxNotifications = 60
        var scheduled = 0

        outerLoop: for day in 0..<reminder.durationDays {
            for timeString in reminder.times {
                guard scheduled < maxNotifications else { break outerLoop }
                guard let trigger = buildTrigger(timeString: timeString, dayOffset: day) else {
                    continue
                }

                let content = buildContent(
                    medicineName: reminder.medicineName,
                    timeString: timeString
                )
                let requestID = notificationID(
                    reminderID: reminder.id,
                    day: day,
                    timeString: timeString
                )
                let request = UNNotificationRequest(
                    identifier: requestID,
                    content: content,
                    trigger: trigger
                )

                try? await center.add(request)
                scheduled += 1
            }
        }
    }

    func cancelAll(for reminderID: UUID) {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let prefix = self.notificationIDPrefix(reminderID: reminderID)
            let idsToRemove = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }


    func rescheduleActive(from store: ReminderStore) async {
        let pending = await center.pendingNotificationRequests()
        let pendingPrefixes = Set(pending.map { $0.identifier })

        let active = await MainActor.run { store.fetchActive() }
        for reminder in active {
            let prefix = notificationIDPrefix(reminderID: reminder.id)
            // If no pending notifications exist for this reminder, reschedule it
            let hasPending = pendingPrefixes.contains { $0.hasPrefix(prefix) }
            if !hasPending {
                await schedule(reminder: reminder)
            }
        }
    }

   

    private func buildContent(medicineName: String, timeString: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "reminder.notification.title".localized
        content.body = String(format: "reminder.notification.body".localized, medicineName, timeString)
        content.sound = .default
        content.categoryIdentifier = notificationCategoryID
        // Store medicine name for tap-through navigation
        content.userInfo = ["medicineName": medicineName]
        return content
    }

    private func buildTrigger(timeString: String, dayOffset: Int) -> UNCalendarNotificationTrigger? {
        // Parse "HH:mm"
        let parts = timeString.split(separator: ":").map { Int($0) }
        guard parts.count == 2,
              let hour = parts[0],
              let minute = parts[1] else {
            return nil
        }

        var components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        // Add the day offset
        guard let targetDate = Calendar.current.date(
            byAdding: .day,
            value: dayOffset,
            to: Date()
        ) else {
            return nil
        }
        var targetComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: targetDate
        )
        targetComponents.hour = hour
        targetComponents.minute = minute
        targetComponents.second = 0

        // Skip triggers in the past (day 0 times that have already passed today)
        if let fireDate = Calendar.current.date(from: targetComponents),
           fireDate < Date() {
            return nil
        }
        _ = components  // suppress unused warning
        return UNCalendarNotificationTrigger(dateMatching: targetComponents, repeats: false)
    }

    private func notificationIDPrefix(reminderID: UUID) -> String {
        "medsy.reminder.\(reminderID.uuidString)"
    }

    private func notificationID(
        reminderID: UUID,
        day: Int,
        timeString: String
    ) -> String {
        "\(notificationIDPrefix(reminderID: reminderID)).day\(day).\(timeString.replacingOccurrences(of: ":", with: "-"))"
    }
}
