//
//  CompleteRequestOnlinePaymentInfoView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import SwiftUI

struct CompleteRequestOnlinePaymentInfoView: View {
    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.online_payment.title".localized,
            systemImage: "lock.shield.fill"
        ) {
            Label {
                Text("complete_request.online_payment.description".localized)
                    .font(MedsyFont.body())
                    .foregroundStyle(AppColor.textPrim)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(AppColor.green)
            }

            paymentBadge(
                title: "complete_request.online_payment.cards".localized,
                systemImage: "creditcard.fill"
            )

            Text("complete_request.online_payment.security".localized)
                .font(MedsyFont.caption(12))
                .foregroundStyle(AppColor.textSec)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func paymentBadge(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(MedsyFont.caption(12))
            .foregroundStyle(AppColor.textPrim)
            .padding(.horizontal, MedsySpacing.sm)
            .padding(.vertical, MedsySpacing.xs)
            .frame(maxWidth: .infinity)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: MedsyRadius.md)
                    .stroke(AppColor.border, lineWidth: 1)
            }
    }
}

#Preview {
    CompleteRequestOnlinePaymentInfoView()
        .padding()
        .background(AppColor.bg)
        .environment(LanguageManager.shared)
}
