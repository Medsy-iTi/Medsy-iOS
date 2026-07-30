//
//  PharmacyCompletedOrderDetailView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

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
                
                PharmacyContactInfoCard(
                    headerStyle: .orderInfo(orderId: String(order.orderNumber), date: order.createdAt),
                    name: order.customerName,
                    phone: order.customerPhone,
                    onContact: {
                        if let url = URL(string: "tel://\(order.customerPhone)") {
                            UIApplication.shared.open(url)
                        }
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
                            if let url = URL(string: "tel://\(order.pharmacistPhone)") {
                                UIApplication.shared.open(url)
                            }
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

