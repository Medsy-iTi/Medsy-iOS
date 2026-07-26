import SwiftUI

struct ReorderToastView: View {
    let state: ReorderState
    let onGoToCart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(accentColor)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppColor.sans(14, .semibold))
                    .foregroundStyle(AppColor.textPrim)

                Text(message)
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
                    .lineLimit(2)
            }

            Spacer(minLength: MedsySpacing.xs)

            if canOpenCart {
                Button("orders.reorder.go_to_cart".localized, action: onGoToCart)
                    .font(AppColor.sans(13, .semibold))
                    .foregroundStyle(AppColor.green)
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColor.textSec)
                    .padding(6)
            }
            .accessibilityLabel("orders.reorder.continue_shopping".localized)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(accentColor.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, y: 5)
        .accessibilityElement(children: .combine)
    }

    private var canOpenCart: Bool {
        switch state {
        case .success, .partial:
            return true
        case .idle, .loading, .failed:
            return false
        }
    }

    private var iconName: String {
        switch state {
        case .success:
            return "checkmark.circle.fill"
        case .partial:
            return "exclamationmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .idle, .loading:
            return "cart"
        }
    }

    private var accentColor: Color {
        switch state {
        case .success:
            return AppColor.successGreen
        case .partial:
            return AppColor.warningYellow
        case .failed:
            return AppColor.errorRed
        case .idle, .loading:
            return AppColor.green
        }
    }

    private var title: String {
        switch state {
        case .success:
            return "orders.reorder.success.title".localized
        case .partial:
            return "orders.reorder.partial.title".localized
        case .failed:
            return "orders.reorder.failed.title".localized
        case .idle, .loading:
            return ""
        }
    }

    private var message: String {
        switch state {
        case .success:
            return "orders.reorder.success.message".localized
        case let .partial(added, total):
            return String(format: "orders.reorder.partial.message".localized, added, total)
        case .failed:
            return "orders.reorder.failed.message".localized
        case .idle, .loading:
            return ""
        }
    }
}
