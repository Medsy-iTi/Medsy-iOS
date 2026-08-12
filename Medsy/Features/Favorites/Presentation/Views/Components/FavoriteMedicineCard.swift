//
//  FavoriteMedicineCard.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import SwiftUI

struct FavoriteMedicineCard: View {
    let product: FavoriteMedicineDisplayModel
    let quantity: Int
    let onToggleFavorite: () -> Void
    let onAdd: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onTap: () -> Void

    @State private var showsRemovalConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            productImage

            Text(displayTitle)
                .font(MedsyFont.title(14))
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 38, alignment: .topLeading)

            if !product.subtitle.isEmpty {
                Text(product.subtitle.uppercased())
                    .font(MedsyFont.caption(12))
                    .foregroundStyle(AppColor.textSec)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Text("product.price_value".localized(product.price))
                .font(MedsyFont.price(17))
                .foregroundStyle(AppColor.green)

            cartControl
        }
        .padding(MedsySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 310, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .fill(AppColor.card)
                .overlay {
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
        }
        .medsyCardShadow()
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .alert("cart.remove_confirmation.title".localized, isPresented: $showsRemovalConfirmation) {
            Button("common.cancel".localized, role: .cancel) {}
            Button("cart.remove_confirmation.action".localized, role: .destructive) { onDecrement() }
        } message: {
            Text("cart.remove_confirmation.message".localized(product.title))
        }
    }

    private var displayTitle: String {
        guard !product.dosageInfo.isEmpty else { return product.title }
        guard product.title.rangeOfCharacter(from: .decimalDigits) == nil else { return product.title }
        return "\(product.title) \(product.dosageInfo)"
    }

    private var dosageBadge: String? {
        let tokens = product.dosageInfo.split(separator: " ")
        guard let first = tokens.first else { return nil }
        guard tokens.count > 1, first.contains(where: \.isNumber) else { return String(first) }
        return "\(first) \(tokens[1])"
    }

    private var productImage: some View {
        ZStack(alignment: .topLeading) {
            MedsyRemoteImage(urlString: product.imageURL, contentMode: .fit) {
                MedsyBrandImageFallback()
            } failure: {
                MedsyBrandImageFallback()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 126)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
            .accessibilityHidden(true)

            if let dosageBadge {
                Text(dosageBadge)
                    .font(MedsyFont.button(12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, MedsySpacing.sm)
                    .padding(.vertical, MedsySpacing.xs)
                    .background(AppColor.green, in: Capsule())
                    .padding(MedsySpacing.xxs)
            }

            FavoriteButton(isFavorite: true, size: 34, action: onToggleFavorite)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(MedsySpacing.xxs)
        }
    }

    @ViewBuilder
    private var cartControl: some View {
        if quantity == 0 {
            Button(action: onAdd) {
                Text("product.add_to_cart".localized)
                    .font(MedsyFont.button(14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(AppColor.green, in: RoundedRectangle(cornerRadius: MedsyRadius.md))
            }
            .buttonStyle(.plain)
        } else {
            HStack(spacing: MedsySpacing.xs) {
                quantityButton(systemName: "minus") {
                    if quantity == 1 { showsRemovalConfirmation = true } else { onDecrement() }
                }
                Text("\(quantity)")
                    .font(MedsyFont.button(14))
                    .foregroundStyle(AppColor.textPrim)
                    .frame(maxWidth: .infinity)
                quantityButton(systemName: "plus", action: onIncrement)
            }
            .frame(height: 42)
            .padding(.horizontal, MedsySpacing.xs)
            .background(AppColor.green.opacity(0.12), in: RoundedRectangle(cornerRadius: MedsyRadius.md))
        }
    }

    private func quantityButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(AppColor.green, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
