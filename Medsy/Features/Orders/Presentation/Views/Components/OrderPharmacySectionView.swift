import SwiftUI

struct OrderPharmacySectionView: View {
    let pharmacy: OrderPharmacyPresentationModel
    let onSelectProduct: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            HStack {
                Label(pharmacy.name, systemImage: "cross.case.fill")
                    .font(AppColor.sans(15, .semibold))
                    .foregroundStyle(AppColor.textPrim)
                Spacer()
                Text(String(format: "orders.price_format".localized, pharmacy.subtotal))
                    .font(MedsyFont.price(14))
                    .foregroundStyle(AppColor.green)
            }

            if pharmacy.items.isEmpty {
                Text("orders.detail.pharmacy_items_empty".localized)
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)
                    .padding(MedsySpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(pharmacy.items.enumerated()), id: \.element.id) { index, item in
                        itemRow(item)
                        if index < pharmacy.items.count - 1 {
                            Divider().background(AppColor.border).padding(.leading, 72)
                        }
                    }
                }
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                )
                .medsyCardShadow()
            }
        }
    }

    private func itemRow(_ item: OrderDetailItemModel) -> some View {
        Button {
            if let productId = item.productId {
                onSelectProduct(productId)
            }
        } label: {
            HStack(spacing: MedsySpacing.sm) {
                OrderProductImageView(imageURL: item.imageURL, size: 48)
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.productName)
                        .font(AppColor.sans(14, .semibold))
                        .foregroundStyle(AppColor.textPrim)
                        .lineLimit(2)
                    if let originalName = item.originalProductName {
                        Text(String(format: "orders.detail.alternative_to".localized, originalName))
                            .font(AppColor.sans(12, .medium))
                            .foregroundStyle(AppColor.green)
                    }
                    Text(String(format: "orders.detail.item_qty_price".localized, item.quantity, item.unitPrice))
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                }
                Spacer()
                Text(String(format: "orders.price_format".localized, item.unitPrice * Double(item.quantity)))
                    .font(AppColor.sans(14, .semibold))
                    .foregroundStyle(AppColor.textPrim)
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.vertical, MedsySpacing.sm)
        }
        .buttonStyle(.plain)
        .disabled(item.productId == nil)
    }
}
