//
//  MedsyProductCard.swift
//  Medsy
//

import SwiftUI

struct MedsyProductCard: View {
    var eyebrow: String? = nil
    var iconName: String = "cross.case.fill"
    var imageURL: String? = nil   // ← new: real product image URL

    var name: String
    var subtitle: String
    var price: String

    var badgeText: String? = nil
    var badgeColor: Color = .green

    var primaryButtonTitle: String
    var secondaryButtonTitle: String? = nil
    var footnote: String? = nil

    var accentColor: Color = MedsyTheme.default.primary
    var cardBackground: Color = .white

    var onPrimaryTap: () -> Void = {}
    var onSecondaryTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let eyebrow {
                Text(eyebrow)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            HStack(spacing: 12) {
                // Product image
                productImage
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(price)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(accentColor)
                }

                Spacer()

                if let badgeText {
                    Text(badgeText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 10) {
                Button(action: onPrimaryTap) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(accentColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                if let secondaryButtonTitle {
                    Button(action: onSecondaryTap) {
                        Text(secondaryButtonTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .overlay(Capsule().stroke(accentColor.opacity(0.4)))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let footnote {
                Text(footnote)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .padding(.bottom, 12)    // ← extra bottom padding per requirement
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var productImage: some View {
        if let urlString = imageURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure, .empty:
                    fallbackIcon
                @unknown default:
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }

    private var fallbackIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(accentColor.opacity(0.12))
            Image(systemName: iconName)
                .foregroundColor(accentColor)
        }
    }
}

#Preview {
    MedsyProductCard(
        eyebrow: "SUGGESTED · OVER THE COUNTER",
        name: "Panadol Extra",
        subtitle: "500 mg · 24 tablets",
        price: "EGP 68",
        primaryButtonTitle: "Add to cart",
        secondaryButtonTitle: "Details",
        footnote: "Ask your pharmacist to confirm the right dose for you."
    )
    .padding()
}
