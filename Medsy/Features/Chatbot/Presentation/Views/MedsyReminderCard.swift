//
//  MedsyReminderCard.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI


struct MedsyReminderCard: View {
    var iconName: String = "bell.fill"
    var title: String
    var subtitle: String

    var accentColor: Color = MedsyTheme.default.primary
    var cardBackground: Color = AppColor.card

    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(accentColor.opacity(0.12))
                Image(systemName: iconName)
                    .foregroundColor(accentColor)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrim)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSec)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(accentColor)
        }
        .padding(14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColor.border.opacity(0.65), lineWidth: 1)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(true) { isOn in
        MedsyReminderCard(
            title: "Daily reminder set",
            subtitle: "Concor 5 mg · every day at 9:00 AM",
            isOn: isOn
        )
        .padding()
    }
}


struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
