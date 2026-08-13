//
//  PharmacyCompletedOrderDetailView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI
import UIKit

// MARK: - Private helper (safe dialer)
@MainActor
private func dial(_ rawNumber: String) {
    let allowedSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+"))
    let cleaned = rawNumber.components(separatedBy: allowedSet.inverted).joined()
    guard !cleaned.isEmpty else { return }
    #if targetEnvironment(simulator)
    print("[Pharmacy] Dial \(cleaned) (simulator – cannot open tel:)")
    #else
    if let url = URL(string: "telprompt://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else if let url = URL(string: "tel:\(cleaned)"), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
    #endif
}

struct PharmacyCompletedOrderDetailView: View {
    let state: CompletedOrderDetailViewState
    let onRetry: () -> Void
    let onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            PharmacyDivider()
            detailContent
        }
        .background(PharmacyColor.bg)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .pharmacyLocalizedEnvironment()
    }

    private var navTitle: String {
        if case .loaded(let order) = state {
            return "completed_order.order_number".localized(String(order.orderNumber))
        }
        return "completed_order.title".localized
    }

    @ViewBuilder
    private var detailContent: some View {
        switch state {
        case .loading:
            PharmacyCompletedOrderDetailLoadingSkeleton()
        case .loaded(let order):
            loadedView(order: order)
        case .error(let message):
            PharmacyErrorView(message: message, onRetry: onRetry)
        case .notFound:
            PharmacyOrderNotFoundView(onBack: onBack)
        }
    }

    private func loadedView(order: CompletedOrderDetailPresentationModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PharmacySpacing.md) {

                PharmacyOrderStatusTrackerView(status: order.status)

                PharmacyContactInfoCard(
                    headerStyle: .orderInfo(orderId: String(order.orderNumber), date: order.createdAt),
                    name: order.customerName,
                    phone: order.customerPhone,
                    onContact: {
                        dial(order.customerPhone)
                    },
                    address: order.deliveryAddress,
                    onLocationTap: order.hasDelivery ? {
                        if let lat = order.deliveryLatitude, let lon = order.deliveryLongitude {
                            let urlString = "maps://?q=\(lat),\(lon)"
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    } : nil
                )
                
                PharmacyOrderItemsCard(
                    items: .constant(order.items.map { completedItem in
                        PharmacyOrderItem(
                            id: String(completedItem.id),
                            productId: completedItem.productId,
                            name: completedItem.productName,
                            spec: "",
                            quantity: completedItem.quantity,
                            price: completedItem.unitPrice,
                            imageName: nil,
                            imageUrl: completedItem.imageUrl,
                            isAvailable: true,
                            selectedOfferProductId: 0,
                            alternativeMedicine: nil,
                            form: nil,
                            strength: nil,
                            packSize: nil
                        )
                    }),
                    deliveryFee: order.deliveryFee,
                    total: order.total,
                    isOfferSubmitted: true,
                    isEditable: false,
                    onSelectAlternative: nil
                )

                
                if let imageUrlString = order.prescriptionImage, let url = URL(string: imageUrlString) {
                    PharmacyPrescriptionCard(uiImage: nil, imageUrl: url) {
                        // Action for enlarging image can go here if needed
                    }
                }
                
                if !order.customerNotes.isEmpty {
                    PharmacyCustomerNotesCard(notes: order.customerNotes)
                }

                if !order.pharmacistName.isEmpty {
                    PharmacyContactInfoCard(
                        headerStyle: .title("completed_order.pharmacist".localized),
                        name: order.pharmacistName,
                        phone: order.pharmacistPhone,
                        onContact: {
                            dial(order.pharmacistPhone)
                        }
                    )
                }

                if !order.pharmacistNotes.isEmpty {
                    PharmacyNotesForCustomerCard(text: .constant(order.pharmacistNotes))
                        .disabled(true)
                }

                PharmacyMoneyDetailsCard(
                    subTotal: order.subTotal,
                    deliveryFee: order.deliveryFee,
                    total: order.total,
                    hasDelivery: order.hasDelivery
                )
            }
            .padding(PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
    }
}

// MARK: - PharmacyOrderStatusTrackerView

private struct PharmacyOrderStatusTrackerView: View {
    let status: PharmacyOrderAPIStatus

    private var steps: [String] {
        ["pharmacy.status.preparing".localized,
         "pharmacy.status.on_the_way".localized,
         "pharmacy.status.delivered".localized]
    }

    /// 0 = Preparing, 1 = On the way, 2 = Delivered, -1 = hide (cancelled)
    private var activeStep: Int {
        switch status {
        case .pending, .accepted, .preparing:               return 0
        case .outForDelivery:                                 return 1
        case .delivered, .completed:                          return 2
        case .cancelled, .expired, .unknown:                  return -1
        }
    }

    var body: some View {
        if activeStep >= 0 {
            HStack(spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    stepView(index: index)
                    if index < steps.count - 1 {
                        connectorLine(filled: index < activeStep)
                    }
                }
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

    private func stepView(index: Int) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .strokeBorder(index <= activeStep ? PharmacyColor.primary : PharmacyColor.border, lineWidth: 2)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(index <= activeStep ? PharmacyColor.primary : PharmacyColor.card)
                    )

                if index <= activeStep {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }

            Text(steps[index])
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(index <= activeStep ? PharmacyColor.primary : PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 90)
    }

    private func connectorLine(filled: Bool) -> some View {
        Rectangle()
            .fill(filled ? PharmacyColor.primary : PharmacyColor.border)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 22)
    }
}
