//
//  CompletedOrderDetailPresentationModel.swift
//  Medsy
//

import Foundation

struct CompletedOrderDetailPresentationModel: Identifiable {
    let id: Int
    let orderNumber: Int
    let customerName: String
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacyAddress: String
    let pharmacyPhone: String
    let pharmacistName: String
    let createdAt: Date
    let items: [CompletedOrderItemPresentationModel]
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let hasDelivery: Bool
}

struct CompletedOrderItemPresentationModel: Identifiable {
    let id: Int
    let productId: Int
    let productName: String
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}

// MARK: - Mock

extension CompletedOrderDetailPresentationModel {
    static let mock = CompletedOrderDetailPresentationModel(
        id: 2,
        orderNumber: 2,
        customerName: "Antoneos Philip",
        pharmacyId: 2,
        pharmacyName: "صيدلية الأمل",
        pharmacyAddress: "Cairo, Egypt",
        pharmacyPhone: "01282670068",
        pharmacistName: "Antoneos Philip",
        createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
        items: [
            CompletedOrderItemPresentationModel(
                id: 2,
                productId: 3,
                productName: "ABIMOL 500 MG 20 TABS",
                imageUrl: "https://cdn.shopify.com/s/files/1/0774/7151/4932/products/abimol-500-mg-20-tablets-7308198.jpg",
                quantity: 1,
                unitPrice: 24,
                totalPrice: 24
            )
        ],
        subTotal: 24,
        deliveryFee: 20,
        total: 44,
        hasDelivery: true
    )
}
