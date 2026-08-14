// PharmacyOrderItemsCard.swift

import SwiftUI

struct PharmacyOrderItemsCard: View {
    @Binding var items: [PharmacyOrderItem]
    let deliveryFee: Double
    let total: Double
    let isOfferSubmitted: Bool
    let isEditable: Bool
    var onSelectAlternative: ((PharmacyOrderItem) -> Void)? = nil

    init(items: Binding<[PharmacyOrderItem]>, deliveryFee: Double, total: Double, isOfferSubmitted: Bool, isEditable: Bool = true, onSelectAlternative: ((PharmacyOrderItem) -> Void)? = nil) {
        self._items = items
        self.deliveryFee = deliveryFee
        self.total = total
        self.isOfferSubmitted = isOfferSubmitted
        self.isEditable = isEditable
        self.onSelectAlternative = onSelectAlternative
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            PharmacySectionHeader(
                title: "pharmacy.request.requested_medicines".localized,
                systemImage: "pills.fill"
            )

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Divider()
                            .overlay(PharmacyColor.border)
                            .padding(.vertical, 12)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                if let imageUrlStr = item.imageUrl, let url = URL(string: imageUrlStr) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                            .redacted(reason: .placeholder)
                                    }
                                } else {
                                    ZStack {
                                        PharmacyColor.primarySoft.opacity(0.5)
                                        Image(systemName: "pills.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(PharmacyColor.primary.opacity(0.7))
                                    }
                                }
                            }
                            .frame(width: 48, height: 48)
                            .padding(4)
                            .background(PharmacyColor.card)
                            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(PharmacyColor.sans(15, .bold))
                                    .foregroundStyle(PharmacyColor.textPrimary)

                                if item.form != nil || item.strength != nil || item.packSize != nil {
                                    HStack(spacing: 6) {
                                        if let form = item.form, !form.isEmpty {
                                            Text(form)
                                                .font(PharmacyColor.sans(11, .medium))
                                                .foregroundStyle(PharmacyColor.primary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(PharmacyColor.primarySoft.opacity(0.5), in: Capsule())
                                        }
                                        if let strength = item.strength, !strength.isEmpty {
                                            Text(strength)
                                                .font(PharmacyColor.sans(11, .medium))
                                                .foregroundStyle(PharmacyColor.textSecondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(PharmacyColor.border, in: Capsule())
                                        }
                                        if let packSize = item.packSize, !packSize.isEmpty {
                                            Text("pharmacy.request.pack_size_label".localized(packSize))
                                                .font(PharmacyColor.sans(11, .medium))
                                                .foregroundStyle(PharmacyColor.textSecondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(PharmacyColor.border, in: Capsule())
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }

                                Text("\(item.quantity) x \(Int(item.price)) \("pharmacy.request.currency_unit".localized)")
                                    .font(PharmacyColor.sans(14, .bold))
                                    .foregroundStyle(PharmacyColor.textSecondary)
                            }

                            Spacer()

                            if isEditable {
                                Button {
                                    items[index].isAvailable.toggle()
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                                            .fill(item.isAvailable ? PharmacyColor.primary.opacity(0.1) : Color.clear)
                                            .frame(width: 36, height: 36)

                                        Image(systemName: item.isAvailable ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundStyle(item.isAvailable ? PharmacyColor.primary : PharmacyColor.textSecondary)
                                    }
                                }
                                .buttonStyle(PharmacyPressableButtonStyle())
                                .disabled(isOfferSubmitted)
                            }
                        }

                        if isEditable {
                            if !item.isAvailable && !isOfferSubmitted {
                                Button {
                                    onSelectAlternative?(item)
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.2.squarepath")
                                            .font(.system(size: 14))
                                        Text("pharmacy.request.select_alternative".localized)
                                            .font(PharmacyColor.sans(14, .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(PharmacyColor.primary, in: RoundedRectangle(cornerRadius: PharmacyRadius.sm))
                                    .foregroundStyle(.white)
                                }
                                .buttonStyle(PharmacyPressableButtonStyle())
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "box.truck.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(PharmacyColor.primary)
                                    Text("pharmacy.request.offer_product".localized(item.name))
                                        .font(PharmacyColor.sans(13, .semibold))
                                        .foregroundStyle(PharmacyColor.primary)
                                    Spacer()
                                    Text("ID: \(item.selectedOfferProductId)")
                                        .font(PharmacyColor.sans(12, .medium))
                                        .foregroundStyle(PharmacyColor.textSecondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(PharmacyColor.primarySoft.opacity(0.3), in: RoundedRectangle(cornerRadius: PharmacyRadius.sm))
                            }
                        }
                    }
                }
            }
            .pharmacyCard(elevation: .subtle)
        }
    }
}
