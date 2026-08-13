//
//  CompleteRequestPaymentMethodView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestPaymentMethodView: View {
    @Environment(\.colorScheme) private var colorScheme
    let selectedMethod: CompleteRequestPaymentMethod
    let onSelect: (CompleteRequestPaymentMethod) -> Void

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.payment.title".localized,
            systemImage: "creditcard",
            backgroundColor: sectionBackgroundColor,
            titleColor: primaryTextColor,
            iconColor: accentColor,
            iconBackgroundColor: iconBackgroundColor,
            borderColor: borderColor,
            shadowColor: colorScheme == .dark ? .clear : AppColor.green.opacity(0.06)
        ) {
            Text("complete_request.payment.subtitle".localized)
                .font(MedsyFont.caption())
                .foregroundStyle(secondaryTextColor)

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

    private var sectionBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#0E1418") : Color(hex: "#FFFFFF")
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "#E1E6E3") : Color(hex: "#181C19")
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "#BEC9C2") : Color(hex: "#414943")
    }

    private var accentColor: Color {
        colorScheme == .dark ? Color(hex: "#27C779") : Color(hex: "#048C4E")
    }

    private var iconBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#123D2B") : Color(hex: "#D6F5E2")
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color(hex: "#3C4741") : Color(hex: "#C0C9C2")
    }
}
