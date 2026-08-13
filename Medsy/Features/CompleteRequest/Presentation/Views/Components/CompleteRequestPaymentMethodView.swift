//
//  CompleteRequestPaymentMethodView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestPaymentMethodView: View {
    let selectedMethod: CompleteRequestPaymentMethod
    let onSelect: (CompleteRequestPaymentMethod) -> Void

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.payment.title".localized,
            systemImage: "creditcard"
        ) {
            Text("complete_request.payment.subtitle".localized)
                .font(MedsyFont.caption())
                .foregroundStyle(AppColor.textSec)

            HStack(alignment: .top, spacing: MedsySpacing.sm) {
                CompleteRequestOptionCard(
                    title: "complete_request.payment.cash".localized,
                    subtitle: "complete_request.payment.cash.subtitle".localized,
                    systemImage: "banknote",
                    isSelected: selectedMethod == .cash,
                    action: { onSelect(.cash) }
                )

                CompleteRequestOptionCard(
                    title: "complete_request.payment.online".localized,
                    subtitle: "complete_request.payment.online.subtitle".localized,
                    systemImage: "creditcard.and.123",
                    isSelected: selectedMethod == .visa,
                    action: { onSelect(.visa) }
                )
            }
        }
    }
}
