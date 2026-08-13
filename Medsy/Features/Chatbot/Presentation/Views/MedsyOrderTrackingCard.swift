//
//  MedsyOrderTrackingCard.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI


struct MedsyOrderTrackingCard: View {
    var label: String
    var orderId: String
    var statusText: String
    var statusColor: Color = .orange

    var itemsSummary: String
    var subtotalText: String

    /// 0.0 ... 1.0
    var progress: Double
    var phaseLabel: String
    var timeLeft: String

    var accentColor: Color = MedsyTheme.default.primary
    var cardBackground: Color = AppColor.card

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(label) · \(orderId)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accentColor)
                Spacer()
                Text(statusText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(itemsSummary)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textPrim)

            Text(subtotalText)
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSec)

            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColor.surfaceContainerHighest)
                        Capsule()
                            .fill(accentColor)
                            .frame(width: geo.size.width * min(max(progress, 0), 1))
                    }
                }
                .frame(height: 6)

                HStack {
                    Text(phaseLabel)
                    Spacer()
                    Text(timeLeft)
                }
                .font(.system(size: 11))
                .foregroundColor(AppColor.textSec)
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColor.border.opacity(0.65), lineWidth: 1)
        }
    }
}

#Preview {
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
    .padding()
}
