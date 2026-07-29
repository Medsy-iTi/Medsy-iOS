//
//  PharmacyContactInfoCard.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyContactInfoCard: View {
    enum HeaderStyle {
        case orderInfo(orderId: String, date: Date)
        case title(String)
        case none
    }
    
    let headerStyle: HeaderStyle
    let name: String
    let phone: String
    let onContact: () -> Void
    
    var address: String? = nil
    var onLocationTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            // Header Row
            switch headerStyle {
            case .orderInfo(let orderId, let date):
                HStack {
                    Text("#\(orderId)")
                        .font(PharmacyColor.sans(18, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Spacer()
                    Text(date.relativeTimeString)
                        .font(PharmacyColor.sans(13, .regular))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            case .title(let title):
                Text(title)
                    .font(PharmacyColor.sans(14, .regular))
                    .foregroundStyle(PharmacyColor.textSecondary)
            case .none:
                EmptyView()
            }

            // Name and Phone Row
            HStack(alignment: .center) {
                Text(name)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Spacer()

                HStack(spacing: PharmacySpacing.sm) {
                    Text(phone)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.primary)
                        
                    Button(action: onContact) {
                        ZStack {
                            Circle()
                                .fill(PharmacyColor.primarySoft)
                                .frame(width: 36, height: 36)

                            Image(systemName: "phone.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(PharmacyColor.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            // Address Row
            if let address = address {
                HStack(alignment: .center) {
                    Text(address.isEmpty ? "pharmacy.orders.address.placeholder".localized : address)
                        .font(PharmacyColor.sans(14, .regular))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .lineLimit(2)

                    Spacer()

                    if let onLocationTap = onLocationTap {
                        Button(action: onLocationTap) {
                            ZStack {
                                Circle()
                                    .fill(PharmacyColor.primarySoft)
                                    .frame(width: 36, height: 36)

                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(PharmacyColor.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}