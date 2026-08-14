//
//  ReminderStore.swift
//  Medsy
//
//  CRUD wrapper around SwiftData for MedReminder objects.
//  @MainActor because ModelContext is not Sendable and is used on the main actor.
//

import Foundation
import SwiftData

@MainActor
final class ReminderStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Insert

    @discardableResult
    func insert(
        medicineName: String,
        times: [String],
        durationDays: Int
    ) -> MedReminder {
        let reminder = MedReminder(
            medicineName: medicineName,
            times: times,
            durationDays: durationDays
        )
        context.insert(reminder)
        try? context.save()
        return reminder
    }

    // MARK: - Fetch

    func fetchAll() -> [MedReminder] {
        let descriptor = FetchDescriptor<MedReminder>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchActive() -> [MedReminder] {
        fetchAll().filter { $0.isActive }
    }

    // MARK: - Delete

    func delete(_ reminder: MedReminder) {
        context.delete(reminder)
        try? context.save()
    }
}
