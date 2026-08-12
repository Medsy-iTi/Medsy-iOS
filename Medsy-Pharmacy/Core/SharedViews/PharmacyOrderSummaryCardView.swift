//
//  PharmacyOrderSummaryCardView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyOrderSummaryCardView<ActionButton: View>: View {
    let orderIdString: String
    let createdAtRelativeString: String
    let statusPillText: String
    let statusPillColor: Color
    let statusPillBgColor: Color
    let customerName: String
    let customerPhone: String?
    let deliveryAddress: String
    let paymentMethodString: String
    let totalAmountString: String
    @ViewBuilder let actionButton: () -> ActionButton

    var body: some View {
        VStack(spacing: PharmacySpacing.sm) {
            HStack {
                Text("pharmacy.orders.order_number".localized(orderIdString))
                    .font(PharmacyColor.sans(17, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .environment(\.layoutDirection, .leftToRight)

                Spacer()

                Label(createdAtRelativeString, systemImage: "bag")
                    .font(PharmacyColor.sans(11, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .labelStyle(PharmacyOrderTimeLabelStyle())
            }

            HStack(alignment: .top, spacing: PharmacySpacing.sm) {
                Text(statusPillText)
                    .font(PharmacyColor.sans(11, .semibold))
                    .foregroundStyle(statusPillColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusPillBgColor, in: Capsule())

                Spacer(minLength: PharmacySpacing.sm)

                VStack(alignment: .trailing, spacing: 5) {
                    Text(customerName)
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    if let phone = customerPhone, !phone.isEmpty {
                        Text(phone)
                            .font(PharmacyColor.sans(13, .medium))
                            .foregroundStyle(PharmacyColor.primaryDark)
                            .environment(\.layoutDirection, .leftToRight)
                    }

                    Label(deliveryAddress.isEmpty ? "pharmacy.orders.address.placeholder".localized : deliveryAddress, systemImage: "location.fill")
                        .font(PharmacyColor.sans(12))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }

            HStack(spacing: PharmacySpacing.xs) {
                Text("pharmacy.orders.payment".localized + ":")
                    .foregroundStyle(PharmacyColor.textSecondary)
                Text(paymentMethodString)
                    .foregroundStyle(PharmacyColor.primaryDark)

                Spacer()

                Text("pharmacy.orders.currency".localized(totalAmountString))
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }
            .font(PharmacyColor.sans(12, .medium))
            
            actionButton()
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous).stroke(PharmacyColor.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        .accessibilityElement(children: .contain)
    }
}

private struct PharmacyOrderTimeLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.title
            configuration.icon
                .foregroundStyle(PharmacyColor.primary)
        }
    }
}
