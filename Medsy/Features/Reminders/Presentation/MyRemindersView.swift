//
//  MyRemindersView.swift
//  Medsy
//
//  Local-only list of medication reminders stored in SwiftData.
//  There is no backend endpoint for this — the device is the sole source of truth (§4b).
//

import SwiftUI
import SwiftData

struct MyRemindersView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \MedReminder.createdAt, order: .reverse)
    private var allReminders: [MedReminder]

    var onBack: () -> Void

    private var activeReminders: [MedReminder] { allReminders.filter { $0.isActive } }
    private var pastReminders: [MedReminder] { allReminders.filter { !$0.isActive } }

    var body: some View {
        ZStack {
            AppColor.bg.ignoresSafeArea()

            if allReminders.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: MedsySpacing.sm) {
                        if !activeReminders.isEmpty {
                            sectionHeader("reminders.section.active".localized)
                            ForEach(activeReminders) { reminder in
                                reminderRow(reminder)
                            }
                        }
                        if !pastReminders.isEmpty {
                            sectionHeader("reminders.section.past".localized)
                                .padding(.top, MedsySpacing.xs)
                            ForEach(pastReminders) { reminder in
                                reminderRow(reminder, dimmed: true)
                            }
                        }
                    }
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.vertical, MedsySpacing.md)
                    .padding(.bottom, MedsySpacing.xl)
                }
            }
        }
        .navigationTitle("reminders.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                MedsyNavBarBackButton(action: onBack)
            }
        }
        .localizedEnvironment()
        .environment(lang)
    }

    // MARK: - Rows

    private func reminderRow(_ reminder: MedReminder, dimmed: Bool = false) -> some View {
        HStack(spacing: MedsySpacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                    .fill(AppColor.warningYellow.opacity(dimmed ? 0.07 : 0.14))
                Image(systemName: "bell.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.warningYellow.opacity(dimmed ? 0.5 : 1.0))
            }
            .frame(width: 36, height: 36)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.medicineName)
                    .font(MedsyFont.bodyMedium(15))
                    .foregroundColor(dimmed ? AppColor.textSec : AppColor.textPrim)

                let timesText = reminder.times.joined(separator: "  •  ")
                Text(timesText)
                    .font(MedsyFont.caption(12))
                    .foregroundColor(AppColor.textSec.opacity(dimmed ? 0.6 : 1.0))

                Text(
                    String(
                        format: "reminders.row.days".localized,
                        reminder.durationDays
                    )
                )
                .font(MedsyFont.caption(11))
                .foregroundColor(AppColor.textSec.opacity(0.6))
            }

            Spacer(minLength: 0)

            if dimmed {
                Text("reminders.row.completed".localized)
                    .font(MedsyFont.caption(10))
                    .foregroundColor(AppColor.textSec.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColor.surface)
                    .clipShape(Capsule())
            }
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border.opacity(0.6), lineWidth: 1)
        }
        .opacity(dimmed ? 0.65 : 1.0)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteReminder(reminder)
            } label: {
                Label("common.delete".localized, systemImage: "trash")
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(AppColor.textSec)
            .padding(.horizontal, 4)
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: MedsySpacing.md) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(AppColor.textSec.opacity(0.4))
            Text("reminders.empty.title".localized)
                .font(MedsyFont.bodyMedium(16))
                .foregroundColor(AppColor.textPrim)
            Text("reminders.empty.subtitle".localized)
                .font(MedsyFont.body(14))
                .foregroundColor(AppColor.textSec)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MedsySpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Delete

    private func deleteReminder(_ reminder: MedReminder) {
        ReminderScheduler.shared.cancelAll(for: reminder.id)
        modelContext.delete(reminder)
        try? modelContext.save()
    }
}
