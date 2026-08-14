//
//  AiChatReminderConfirmCard.swift
//  Medsy
//
//  Shown under the assistant bubble when the backend returns a SET_REMINDER
//  response with a non-null `reminder` field. Displays the scheduled times and
//  a link to "My Reminders" so the user can manage or cancel it later.
//

import SwiftUI

struct AiChatReminderConfirmCard: View {
    let reminder: AIChatReminder
    var onViewReminders: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {

            // Header
            HStack(spacing: MedsySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColor.warningYellow.opacity(0.18))
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.warningYellow)
                }
                .frame(width: 30, height: 30)

                Text("reminders.card.title".localized)
                    .font(MedsyFont.bodyMedium(14))
                    .foregroundColor(AppColor.warningYellow)
            }

            Divider()
                .background(AppColor.warningYellow.opacity(0.25))

            // Medicine name
            Text(reminder.medicineName)
                .font(MedsyFont.bodyMedium(15))
                .foregroundColor(AppColor.textPrim)

            // Times chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MedsySpacing.xs) {
                    ForEach(reminder.times, id: \.self) { time in
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10, weight: .semibold))
                            Text(time)
                                .font(MedsyFont.bodyMedium(12))
                        }
                        .foregroundColor(AppColor.warningYellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColor.warningYellow.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }

            // Duration
            Text(
                String(format: "reminders.card.duration".localized, reminder.durationDays)
            )
            .font(MedsyFont.caption(12))
            .foregroundColor(AppColor.textSec)

            // View Reminders button
            Button(action: onViewReminders) {
                HStack(spacing: MedsySpacing.xs) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 12, weight: .semibold))
                    Text("reminders.card.view_all".localized)
                        .font(MedsyFont.bodyMedium(13))
                }
                .foregroundColor(AppColor.warningYellow)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(AppColor.warningYellow.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.warningYellow.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.warningYellow.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    AiChatReminderConfirmCard(
        reminder: AIChatReminder(
            medicineName: "Concor",
            times: ["09:00", "21:00"],
            durationDays: 7
        )
    )
    .padding()
}
