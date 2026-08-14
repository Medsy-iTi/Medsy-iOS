import SwiftUI

struct PharmacyOrderTotalCard: View {
    let total: Double
    var paymentMethod: String? = nil
    var onViewPaymentSummary: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: PharmacySpacing.sm) {
            if let paymentMethod, !paymentMethod.isEmpty {
                HStack {
                    Text("pharmacy.request.payment_method_label".localized)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    Spacer()
                    Text(paymentMethodText(paymentMethod))
                        .font(PharmacyColor.sans(14, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                }
                Divider()
            }

            HStack(alignment: .center, spacing: PharmacySpacing.sm) {
                PharmacyIconTile(
                    systemImage: "banknote.fill",
                    tint: PharmacyColor.success,
                    background: PharmacyColor.successSoft,
                    size: 44,
                    iconSize: 18
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("pharmacy.request.order_total_header".localized)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    if onViewPaymentSummary != nil {
                        Button(action: {
                            onViewPaymentSummary?()
                        }) {
                            Text("pharmacy.request.view_payment_summary".localized)
                                .font(PharmacyColor.sans(12, .semibold))
                                .foregroundStyle(PharmacyColor.primary)
                        }
                        .buttonStyle(PharmacyPressableButtonStyle())
                    }
                }

                Spacer()

                Text("\(Int(total)) \("pharmacy.request.currency_unit".localized)")
                    .font(PharmacyColor.sans(20, .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }
        }
        .pharmacyCard(elevation: .raised)
    }

    private func paymentMethodText(_ raw: String) -> String {
        let upper = raw.uppercased()
        if upper == "CARD" || upper == "ONLINE" || upper == "VISA" || upper == "STRIPE" {
            return "pharmacy.payment.card".localized
        }
        return "pharmacy.payment.cash".localized
    }
}
