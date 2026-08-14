//
//  PharmacyHeroCard.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyHeroCard: View {
    let pharmacyName: String
    let address: String
    let pharmacyId: Int?
    let isOpen: Bool

    var body: some View {
        VStack(spacing: 0) {
            PharmacyStorefrontIllustration()
                .frame(height: 142)
                .frame(maxWidth: .infinity)
                .background(PharmacyColor.primarySoft)

            VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: PharmacySpacing.xs) {
                    Text(pharmacyName)
                        .font(PharmacyColor.sans(19, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                        .lineLimit(2)

                    Spacer(minLength: PharmacySpacing.xs)

                    Text((isOpen ? "pharmacy.home.online" : "pharmacy.home.closed").localized)
                        .font(PharmacyColor.sans(11, .semibold))
                        .foregroundStyle(isOpen ? PharmacyColor.success : PharmacyColor.danger)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            (isOpen ? PharmacyColor.success : PharmacyColor.danger).opacity(0.12),
                            in: Capsule()
                        )
                }

                HStack(alignment: .center, spacing: PharmacySpacing.sm) {
                    PharmacyIconTile(
                        systemImage: "location.fill",
                        size: 38,
                        iconSize: 15
                    )

                    Text(address)
                        .font(PharmacyColor.sans(13, .medium))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .lineLimit(2)

                    Spacer(minLength: 0)
                }

                HStack(alignment: .center, spacing: PharmacySpacing.sm) {
                    PharmacyIconTile(
                        systemImage: "number",
                        tint: PharmacyColor.secondary,
                        background: PharmacyColor.secondarySoft,
                        size: 38,
                        iconSize: 15
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("pharmacy.home.pharmacy_number".localized)
                            .font(PharmacyColor.sans(11, .medium))
                            .foregroundStyle(PharmacyColor.textSecondary)
                        Text(pharmacyId.map { "#\($0)" } ?? "—")
                            .font(PharmacyColor.sans(14, .bold))
                            .foregroundStyle(PharmacyColor.textPrimary)
                            .environment(\.layoutDirection, .leftToRight)
                    }

                    Spacer(minLength: 0)
                }
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card)
        }
        .pharmacyCard(cornerRadius: PharmacyRadius.xl, padding: nil, elevation: .raised)
        .accessibilityElement(children: .contain)
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

#if DEBUG
#Preview("Pharmacy Details · Light · English") {
    PharmacyPreviewHost(isDarkMode: false, language: .english) {
        PharmacyHeroCard(
            pharmacyName: "Medsy Community Pharmacy",
            address: "12 Tahrir Street, Downtown, Cairo",
            pharmacyId: 1024,
            isOpen: true
        )
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.bg)
    }
}

#Preview("Pharmacy Details · Dark · Arabic") {
    PharmacyPreviewHost(isDarkMode: true, language: .arabic) {
        PharmacyHeroCard(
            pharmacyName: "صيدلية ميدسي المجتمعية",
            address: "١٢ شارع التحرير، وسط البلد، القاهرة",
            pharmacyId: 1024,
            isOpen: false
        )
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.bg)
    }
}
#endif
