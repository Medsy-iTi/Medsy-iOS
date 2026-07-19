//
//  PharmacyCardView.swift
//  Medsy-Pharmacy
//

import SwiftUI

// MARK: - With Pharmacy

struct PharmacyCardView: View {
    let profile: PharmacyProfile
    let onEdit: (() -> Void)?
    let onLeave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            // Header
            HStack(spacing: PharmacySpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                        .fill(PharmacyColor.primary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(PharmacyColor.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.pharmacyName ?? "pharmacy_card.unknown".localized)
                        .font(PharmacyColor.sans(15, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                        .lineLimit(1)

                    Text("pharmacy_card.your_pharmacy".localized)
                        .font(PharmacyColor.sans(12))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }

                Spacer(minLength: 0)

                if let onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PharmacyColor.primary)
                            .frame(width: 32, height: 32)
                            .background(PharmacyColor.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("pharmacy_card.edit".localized)
                }
            }

            // Divider
            Divider()
                .overlay(PharmacyColor.border)

            // Details
            if let address = profile.pharmacyAddress, !address.isEmpty {
                pharmacyDetailRow(icon: "mappin.and.ellipse", text: address)
            }

            if let phone = profile.pharmacyPhoneNumber, !phone.isEmpty {
                pharmacyDetailRow(icon: "phone", text: phone)
            }

            // Leave Button
            Button(role: .destructive, action: onLeave) {
                HStack(spacing: 6) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                    Text("pharmacy_card.leave".localized)
                        .font(PharmacyColor.sans(13, .semibold))
                }
                .foregroundStyle(PharmacyColor.danger)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 38)
                .background(PharmacyColor.danger.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }

    private func pharmacyDetailRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(PharmacyColor.textSecondary)
                .frame(width: 18)
            Text(text)
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textPrimary)
                .lineLimit(2)
        }
    }
}

// MARK: - No Pharmacy Assigned

struct NoPharmacyCardView: View {
    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                    .fill(PharmacyColor.textSecondary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "building.2")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("pharmacy_card.not_assigned".localized)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Text("pharmacy_card.not_assigned_subtitle".localized)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}
