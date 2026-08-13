//
//  MedsyDemoScreen.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI


struct MedsyDemoScreen: View {
    @State private var reminderOn = true
    @State private var draftMessage = ""

    private let theme = MedsyTheme.default

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    MedsyDisclaimerBanner(
                        text: "Information only — not a medical diagnosis. Always confirm with a pharmacist or doctor."
                    )

                    MedsyChatBubble(text: "Can you read this and explain it simply?", isUser: true)

                    MedsyChatBubble(
                        text: "I read your prescription — it's for high blood pressure and cholesterol. In simple words: one medicine keeps your pressure down, the other keeps your arteries clean. I found both in the Medsy catalog:",
                        isUser: false
                    )

                    MedsyProductCard(
                        name: "Concor 5 mg",
                        subtitle: "For blood pressure · 1 tablet every morning",
                        price: "EGP 96",
                        badgeText: "98% match",
                        badgeColor: .green,
                        primaryButtonTitle: "Add to cart"
                    )

                    MedsyProductCard(
                        name: "Lipitor 20 mg",
                        subtitle: "For cholesterol · 1 tablet at night",
                        price: "EGP 210",
                        badgeText: "Check me",
                        badgeColor: theme.warning,
                        primaryButtonTitle: "Add to cart"
                    )

                    MedsyReminderCard(
                        title: "Daily reminder set",
                        subtitle: "Concor 5 mg · every day at 9:00 AM",
                        isOn: $reminderOn
                    )

                    MedsyOrderTrackingCard(
                        label: "REORDER · REQUEST",
                        orderId: "#4218",
                        statusText: "Searching pharmacies",
                        itemsSummary: "Concor 5 mg ×1 · Lipitor 20 mg ×1",
                        subtotalText: "Fixed subtotal EGP 306 · searching within 500 m",
                        progress: 0.55,
                        phaseLabel: "Phase 1",
                        timeLeft: "07:12 left"
                    )

                    HStack {
                        MedsyQuickActionChip(title: "Track my order")
                        MedsyQuickActionChip(title: "Reorder my usual meds")
                    }
                }
                .padding(16)
            }

            MedsyChatInputBar(text: $draftMessage, placeholder: "Message Medsy AI...")
                .padding(12)
        }
        .background(AppColor.bg)
    }

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(theme.primary)
                Image(systemName: "plus").foregroundColor(.white)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 0) {
                Text("Medsy AI").font(.system(size: 15, weight: .semibold)).foregroundColor(AppColor.textPrim)
                Text("Online").font(.system(size: 11)).foregroundColor(AppColor.successGreen)
            }
            Spacer()
        }
        .padding(12)
    }
}

#Preview {
    MedsyDemoScreen()
}
