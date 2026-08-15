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
    @State private var showAddSheet = false
    @State private var showDeleteAlert = false
    @State private var reminderToDelete: MedReminder?

    @Query(sort: \MedReminder.createdAt, order: .reverse)
    private var allReminders: [MedReminder]

    var onBack: () -> Void

    private var activeReminders: [MedReminder] { allReminders.filter { $0.isActive } }
    private var pastReminders:   [MedReminder] { allReminders.filter { !$0.isActive } }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
                    .padding(.bottom, 100)
                }
            }

            // Floating "+ Add reminder" button (matches design)
            Button {
                showAddSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                    Text("reminders.add_button".localized)
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(AppColor.green)
                .clipShape(Capsule())
                .shadow(color: AppColor.green.opacity(0.35), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.bottom, MedsySpacing.xl)
            .padding(.trailing, MedsySpacing.md)
        }
        .navigationTitle("reminders.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddSheet) {
            AddReminderSheet { medicineName, times, days in
                let store = ReminderStore(context: modelContext)
                let reminder = store.insert(medicineName: medicineName, times: times, durationDays: days)
                Task { await ReminderScheduler.shared.schedule(reminder: reminder) }
            }
        }
        .alert("reminders.delete.title".localized, isPresented: $showDeleteAlert, presenting: reminderToDelete) { reminder in
            Button("common.cancel".localized, role: .cancel) { }
            Button("common.delete".localized, role: .destructive) {
                deleteReminder(reminder)
            }
        } message: { _ in
            Text("reminders.delete.message".localized)
        }
        .localizedEnvironment()
        .environment(lang)
    }

    // MARK: - Rows

    private func reminderRow(_ reminder: MedReminder, dimmed: Bool = false) -> some View {
        HStack(spacing: MedsySpacing.md) {
            // Clock icon (matching screenshot)
            ZStack {
                RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                    .fill(AppColor.green.opacity(dimmed ? 0.07 : 0.14))
                Image(systemName: "alarm")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.green.opacity(dimmed ? 0.5 : 1.0))
            }
            .frame(width: 36, height: 36)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.medicineName)
                    .font(MedsyFont.bodyMedium(15))
                    .foregroundColor(dimmed ? AppColor.textSec : AppColor.textPrim)

                // Show formatted local times
                let timesText = reminder.times
                    .compactMap { t -> String? in
                        let parts = t.split(separator: ":").compactMap { Int($0) }
                        guard parts.count == 2 else { return t }
                        var c = DateComponents(); c.hour = parts[0]; c.minute = parts[1]
                        guard let d = Calendar.current.date(from: c) else { return t }
                        return DateFormatter.localizedString(from: d, dateStyle: .none, timeStyle: .short)
                    }
                    .joined(separator: "  •  ")
                Text(timesText)
                    .font(MedsyFont.caption(12))
                    .foregroundColor(AppColor.textSec.opacity(dimmed ? 0.6 : 1.0))

                // Duration + end date
                let endDate = Calendar.current.date(
                    byAdding: .day, value: reminder.durationDays, to: reminder.createdAt
                ) ?? reminder.createdAt
                Text(String(format: "reminders.row.duration_ends".localized, reminder.durationDays, endDate.formatted(date: .abbreviated, time: .omitted)))
                    .font(MedsyFont.caption(11))
                    .foregroundColor(AppColor.textSec.opacity(0.6))

                if reminder.isActive {
                    Text("reminders.row.active".localized)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColor.green)
                }
            }

            Spacer(minLength: 0)

            // Visible trash button
            Button {
                reminderToDelete = reminder
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red.opacity(0.85))
                    .padding(8)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
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
                reminderToDelete = reminder
                showDeleteAlert = true
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
            Button {
                showAddSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                    Text("reminders.add_button".localized).font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColor.green)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, MedsySpacing.sm)
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

private struct TimeSelection: Identifiable, Equatable {
    let id = UUID()
    var date: Date
}

// MARK: - Add Reminder Sheet

private struct AddReminderSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (_ medicineName: String, _ times: [String], _ durationDays: Int) -> Void

    @State private var medicineName = ""
    @State private var selectedTimes: [TimeSelection] = [TimeSelection(date: Date())]
    @State private var durationDays: Int = 7

    private var isValid: Bool {
        !medicineName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("reminders.add.medicine_name".localized, text: $medicineName)
                        .autocorrectionDisabled()
                } header: {
                    Text("reminders.add.medicine_section".localized)
                }

                Section {
                    ForEach($selectedTimes) { $timeSelection in
                        HStack {
                            DatePicker(
                                "reminders.add.time_label".localized,
                                selection: $timeSelection.date,
                                displayedComponents: .hourAndMinute
                            )
                            if selectedTimes.count > 1 {
                                Button {
                                    if let index = selectedTimes.firstIndex(where: { $0.id == timeSelection.id }) {
                                        selectedTimes.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    if selectedTimes.count < 4 {
                        Button {
                            selectedTimes.append(TimeSelection(date: Date()))
                        } label: {
                            Label("reminders.add.add_time".localized, systemImage: "plus.circle")
                                .foregroundColor(AppColor.green)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("reminders.add.times_section".localized)
                }

                Section {
                    Stepper(
                        String(format: "reminders.add.days".localized, durationDays),
                        value: $durationDays,
                        in: 1...90
                    )
                } header: {
                    Text("reminders.add.duration_section".localized)
                }
            }
            .navigationTitle("reminders.add.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
                        let timeStrings = selectedTimes.map { timeSelection -> String in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: timeSelection.date)
                            return String(format: "%02d:%02d", comps.hour ?? 0, comps.minute ?? 0)
                        }
                        onSave(
                            medicineName.trimmingCharacters(in: .whitespaces),
                            timeStrings,
                            durationDays
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
