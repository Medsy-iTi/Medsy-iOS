//
//  CartItemRow.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartItemRow: View {
    @State private var showsRemovalConfirmation = false

    let item: CartDisplayItem
    let onSelect: () -> Void
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Button(action: onSelect) {
                itemSummary
            }
            .buttonStyle(.plain)

            HStack(spacing: MedsySpacing.sm) {
                quantityStepper

                Spacer()

                Button {
                    showsRemovalConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColor.danger)
                        .frame(width: 38, height: 38)
                        .background(AppColor.danger.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("cart.remove".localized)
            }
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .alert("cart.remove_confirmation.title".localized, isPresented: $showsRemovalConfirmation) {
            Button("common.cancel".localized, role: .cancel) {}
            Button("cart.remove_confirmation.action".localized, role: .destructive, action: onRemove)
        } message: {
            Text("cart.remove_confirmation.message".localized(item.name))
        }
    }

    private var itemSummary: some View {
        HStack(alignment: .top, spacing: MedsySpacing.md) {
            productImage

            HStack(alignment: .top, spacing: MedsySpacing.sm) {
                VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                    Text(item.name)
                        .font(MedsyFont.title(17))
                        .foregroundStyle(AppColor.textPrim)
                        .lineLimit(2)

                    Text(item.dosageInfo)
                        .font(MedsyFont.caption(13))
                        .foregroundStyle(AppColor.textSec)
                        .lineLimit(1)
                }

                Spacer(minLength: MedsySpacing.sm)

                VStack(alignment: .trailing, spacing: MedsySpacing.xxs) {
                    Text(formattedPrice(item.lineTotal))
                        .font(MedsyFont.price(16))
                        .foregroundStyle(AppColor.textPrim)
                        .lineLimit(1)

                    Text(formattedUnitPrice)
                        .font(MedsyFont.caption(12))
                        .foregroundStyle(AppColor.textSec)
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var productImage: some View {
        MedsyRemoteImage(urlString: item.imageUrl, contentMode: .fit) {
            MedsyBrandImageFallback()
        } failure: {
            MedsyBrandImageFallback()
        }
        .frame(width: 56, height: 56)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
    }

    private var quantityStepper: some View {
        HStack(spacing: MedsySpacing.sm) {
            Button {
                if item.quantity <= 1 {
                    showsRemovalConfirmation = true
                } else {
                    onDecrease()
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .bold))
                    .frame(width: 32, height: 32)
            }

            Text("\(item.quantity)")
                .font(MedsyFont.button(15))
                .foregroundStyle(AppColor.textPrim)
                .frame(minWidth: 26)

            Button(action: onIncrease) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                    .frame(width: 32, height: 32)
            }
        }
        .foregroundStyle(AppColor.green)
        .background(AppColor.pill)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("cart.quantity".localized)
    }

    private var formattedUnitPrice: String {
        "cart.unit_price_format".localized(formattedPrice(item.unitPrice))
    }

    private func formattedPrice(_ value: Double) -> String {
        String(format: "%.2f %@", value, "cart.currency".localized)
    }
}
