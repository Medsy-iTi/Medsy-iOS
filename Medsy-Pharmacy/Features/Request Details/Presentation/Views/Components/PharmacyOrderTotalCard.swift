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

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("pharmacy.request.order_total_header".localized)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Button(action: {
                        onViewPaymentSummary?()
                    }) {
                        Text("pharmacy.request.view_payment_summary".localized)
                            .font(PharmacyColor.sans(12, .semibold))
                            .foregroundStyle(PharmacyColor.primary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text("\(Int(total)) \("pharmacy.request.currency_unit".localized)")
                    .font(PharmacyColor.sans(20, .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }

    private func paymentMethodText(_ raw: String) -> String {
        let upper = raw.uppercased()
        if upper == "CARD" || upper == "ONLINE" || upper == "VISA" || upper == "STRIPE" {
            return "pharmacy.payment.card".localized
        }
        return "pharmacy.payment.cash".localized
    }
}
