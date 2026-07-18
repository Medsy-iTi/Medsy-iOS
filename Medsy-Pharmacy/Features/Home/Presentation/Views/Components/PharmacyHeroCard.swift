//
//  PharmacyHeroCard.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyHeroCard: View {
    var body: some View {
        VStack(spacing: 0) {
            PharmacyStorefrontIllustration()
                .frame(height: 142)
                .frame(maxWidth: .infinity)
                .background(PharmacyColor.primarySoft)

            VStack(spacing: PharmacySpacing.xs) {
                HStack(spacing: PharmacySpacing.xs) {
                    Text("pharmacy.home.pharmacy_name".localized)
                        .font(PharmacyColor.sans(17, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Text("pharmacy.home.online".localized)
                        .font(PharmacyColor.sans(10, .semibold))
                        .foregroundStyle(PharmacyColor.success)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(PharmacyColor.successSoft, in: Capsule())
                }

                Label("pharmacy.home.address".localized, systemImage: "location.fill")
                    .font(PharmacyColor.sans(12, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)

                Divider().overlay(PharmacyColor.border)
                    .padding(.vertical, PharmacySpacing.xxs)

                HStack {
                    Label {
                        Text("pharmacy.home.rating".localized + " " + "pharmacy.home.reviews".localized(256))
                    } icon: {
                        Image(systemName: "star.fill").foregroundStyle(PharmacyColor.warning)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("pharmacy.home.pharmacy_number".localized)
                            .font(PharmacyColor.sans(10, .medium))
                            .foregroundStyle(PharmacyColor.textSecondary)
                        Text("PH123456")
                            .font(PharmacyColor.sans(12, .bold))
                            .foregroundStyle(PharmacyColor.textPrimary)
                    }
                }
                .font(PharmacyColor.sans(12, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card)
        }
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.xl, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.xl, style: .continuous).stroke(PharmacyColor.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 14, y: 6)
    }
}

private struct PharmacyStorefrontIllustration: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach([0.31, 0.9], id: \.self) { position in
                VStack(spacing: -3) {
                    Image(systemName: "leaf.fill").font(.system(size: 30)).rotationEffect(.degrees(position < 0.5 ? -35 : 35))
                    RoundedRectangle(cornerRadius: 2).frame(width: 4, height: 35)
                }
                .foregroundStyle(PharmacyColor.success.opacity(0.75))
                .position(x: position * 290, y: 105)
            }

            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 3).fill(PharmacyColor.primaryDark).frame(width: 112, height: 10)
                    Image(systemName: "cross.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(PharmacyColor.primary, in: Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .offset(y: -4)
                }
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index.isMultiple(of: 2) ? .white : PharmacyColor.primary)
                            .frame(width: 28, height: 14)
                    }
                }
                .overlay(alignment: .top) { Rectangle().fill(PharmacyColor.primary).frame(height: 4) }
                HStack(spacing: 8) {
                    PharmacyStoreWindow()
                    PharmacyStoreWindow()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(width: 130, height: 60)
                .background(PharmacyColor.surface)
            }
        }
    }
}

private struct PharmacyStoreWindow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(PharmacyColor.primary)
            .frame(width: 42, height: 34)
            .overlay(RoundedRectangle(cornerRadius: 1).stroke(PharmacyColor.primaryDark, lineWidth: 3))
    }
}
