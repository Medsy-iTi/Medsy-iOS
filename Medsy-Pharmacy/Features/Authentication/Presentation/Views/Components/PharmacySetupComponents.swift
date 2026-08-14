import SwiftUI

struct PharmacySetupReadOnlyField: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text(title)
                .font(PharmacyColor.sans(12, .semibold))
                .foregroundStyle(PharmacyColor.textSecondary)

            HStack(spacing: PharmacySpacing.sm) {
                Image(systemName: systemImage)
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 20)

                Text(value.isEmpty ? "pharmacy.setup.location.not_selected".localized : value)
                    .font(PharmacyColor.sans(15))
                    .foregroundStyle(value.isEmpty ? PharmacyColor.textSecondary : PharmacyColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, PharmacySpacing.md)
            .frame(minHeight: 54)
            .background(PharmacyColor.primarySoft, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct PharmacyLicenseSelectionView: View {
    let fileName: String?
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PharmacySpacing.md) {
                PharmacyIconTile(systemImage: "doc.fill", size: 42, iconSize: 18)

                VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                    Text(fileName ?? "pharmacy.setup.license.select".localized)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                        .lineLimit(1)

                    Text("pharmacy.setup.license.requirements".localized)
                        .font(PharmacyColor.sans(12))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }

                Spacer()

                if isLoading {
                    ProgressView().tint(PharmacyColor.primary)
                } else {
                    Image(systemName: fileName == nil ? "square.and.arrow.up" : "checkmark.circle.fill")
                        .foregroundStyle(fileName == nil ? PharmacyColor.primary : PharmacyColor.success)
                }
            }
            .pharmacyCard(elevation: .subtle)
        }
        .buttonStyle(PharmacyPressableButtonStyle())
        .disabled(isLoading)
    }
}
