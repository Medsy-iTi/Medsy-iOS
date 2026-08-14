import SwiftUI

struct CategoryProductCard: View {
    @Binding var product: MedsyProduct
    let onAdd: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleFavorite: () -> Void
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

            if !subtitle.isEmpty {
                Text(subtitle.uppercased())
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
            Button("cart.remove_confirmation.action".localized, role: .destructive) {
                product.quantity = 0
                onDecrement()
            }
        } message: {
            Text("cart.remove_confirmation.message".localized(product.name))
        }
    }

    private var displayTitle: String {
        guard !product.dosageInfo.isEmpty else { return product.name }
        guard product.name.rangeOfCharacter(from: .decimalDigits) == nil else { return product.name }
        return "\(product.name) \(product.dosageInfo)"
    }

    private var subtitle: String {
        product.scientificName.isEmpty ? product.badgeText : product.scientificName
    }

    private var dosageBadge: String? {
        let tokens = product.dosageInfo.split(separator: " ")
        guard let first = tokens.first else { return nil }
        guard tokens.count > 1, first.contains(where: \.isNumber) else {
            return String(first)
        }
        return "\(first) \(tokens[1])"
    }

    private var productImage: some View {
        ZStack(alignment: .topLeading) {
            MedsyRemoteImage(urlString: product.imageUrl, contentMode: .fit) {
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

            FavoriteButton(
                isFavorite: product.isFavorite,
                size: 34,
                action: onToggleFavorite
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(MedsySpacing.xxs)
        }
    }

    @ViewBuilder
    private var cartControl: some View {
        if product.quantity == 0 {
            Button {
                product.quantity = 1
                onAdd()
            } label: {
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
                    if product.quantity == 1 {
                        showsRemovalConfirmation = true
                    } else {
                        product.quantity -= 1
                        onDecrement()
                    }
                }

                Text("\(product.quantity)")
                    .font(MedsyFont.button(14))
                    .foregroundStyle(AppColor.textPrim)
                    .frame(maxWidth: .infinity)

                quantityButton(systemName: "plus") {
                    product.quantity += 1
                    onIncrement()
                }
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
