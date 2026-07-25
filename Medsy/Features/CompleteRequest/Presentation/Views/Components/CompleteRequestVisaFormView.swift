//
//  CompleteRequestVisaFormView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI
import UIKit

struct CompleteRequestVisaFormView: View {
    @Binding var cardholderName: String
    @Binding var cardNumber: String
    @Binding var expiry: String
    @Binding var cvv: String
    let errorMessage: (CompleteRequestCardField) -> String?
    let onCardNumberChange: () -> Void
    let onExpiryChange: () -> Void
    let onCVVChange: () -> Void

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.card.title".localized,
            systemImage: "lock.shield"
        ) {
            field(
                title: "complete_request.card.cardholder".localized,
                text: $cardholderName,
                field: .cardholderName,
                contentType: .name
            )

            field(
                title: "complete_request.card.number".localized,
                text: $cardNumber,
                field: .cardNumber,
                keyboard: .numberPad,
                contentType: .creditCardNumber
            )
            .onChange(of: cardNumber) {
                onCardNumberChange()
            }

            HStack(alignment: .top, spacing: MedsySpacing.sm) {
                field(
                    title: "complete_request.card.expiry".localized,
                    text: $expiry,
                    field: .expiry,
                    keyboard: .numberPad
                )
                .onChange(of: expiry) {
                    onExpiryChange()
                }

                field(
                    title: "complete_request.card.cvv".localized,
                    text: $cvv,
                    field: .cvv,
                    keyboard: .numberPad,
                    isSecure: true
                )
                .onChange(of: cvv) {
                    onCVVChange()
                }
            }

            Label(
                "complete_request.card.security".localized,
                systemImage: "lock.fill"
            )
            .font(MedsyFont.caption(12))
            .foregroundStyle(AppColor.textSec)
        }
    }

    private func field(
        title: String,
        text: Binding<String>,
        field: CompleteRequestCardField,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        isSecure: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            Text(title)
                .font(MedsyFont.caption())
                .foregroundStyle(AppColor.textSec)

            Group {
                if isSecure {
                    SecureField(title, text: text)
                } else {
                    TextField(title, text: text)
                }
            }
            .keyboardType(keyboard)
            .textContentType(contentType)
            .textInputAutocapitalization(field == .cardholderName ? .words : .never)
            .autocorrectionDisabled(field != .cardholderName)
            .padding(.horizontal, MedsySpacing.sm)
            .frame(height: 48)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: MedsyRadius.md)
                    .stroke(errorMessage(field) == nil ? AppColor.border : AppColor.danger, lineWidth: 1)
            }

            if let message = errorMessage(field) {
                Text(message)
                    .font(MedsyFont.caption(11))
                    .foregroundStyle(AppColor.danger)
            }
        }
    }
}
