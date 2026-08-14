//
//  MedReminder.swift
//  Medsy
//
//  SwiftData model that persists a single medication reminder.
//  AlarmManager-equivalent in iOS: reminders are stored here and
//  UNCalendarNotificationTrigger fires the actual system notifications.
//

import Foundation
import SwiftData

@Model
final class MedReminder {
    /// Stable identifier used to group notification request IDs.
    @Attribute(.unique) var id: UUID
    /// Human-readable medicine name shown in the notification.
    var medicineName: String
    /// 24-hour "HH:mm" strings — one entry per daily alarm time.
    var times: [String]
    /// Number of days the medication course runs.
    var durationDays: Int
    /// Moment the reminder was created / scheduled.
    var createdAt: Date

    /// Whether this reminder is still within its active window.
    var isActive: Bool {
        let endDate = Calendar.current.date(
            byAdding: .day,
            value: durationDays,
            to: createdAt
        ) ?? createdAt
        return Date() < endDate
    }

    init(
        id: UUID = UUID(),
        medicineName: String,
        times: [String],
        durationDays: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.medicineName = medicineName
        self.times = times
        self.durationDays = durationDays
        self.createdAt = createdAt
    }
}
