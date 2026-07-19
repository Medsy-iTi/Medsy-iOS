import SwiftUI

struct ProfileMenuRow: View {
    let icon: String
    let iconTint: Color
    let title: String
    var subtitle: String? = nil

    init(
        icon: String,
        iconTint: Color = PharmacyColor.primary,
        title: String,
        subtitle: String? = nil
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ZStack {
                Circle()
                    .fill(iconTint.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconTint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: PharmacySpacing.xs)

            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(PharmacyColor.textSecondary.opacity(0.6))
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm + 2)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
