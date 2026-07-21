//
//  OrderPresentationModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

struct OrderPresentationModel: Identifiable {
    let id: Int
    let orderNumber: Int
    let pharmacyName: String
    let status: OrderStatusPresentation
    let fulfillmentType: OrderFulfillmentType
    let date: Date
    let totalPrice: Double
    let itemCount: Int
}

struct OrderDetailPresentationModel: Identifiable {
    let id: Int
    let orderNumber: Int
    let pharmacyName: String
    let pharmacyId: Int
    let status: OrderStatusPresentation
    let fulfillmentType: OrderFulfillmentType
    let date: Date
    let items: [OrderDetailItemModel]
    let itemsSubtotal: Double
    let deliveryFee: Double?
    let totalPrice: Double
}

struct OrderDetailItemModel: Identifiable {
    let id: Int
    let productName: String
    let originalProductName: String?
    let quantity: Int
    let unitPrice: Double
}


extension OrderPresentationModel {
    static let mockOrders: [OrderPresentationModel] = [
        OrderPresentationModel(
            id: 1258, orderNumber: 1258,
            pharmacyName: "صيدلية الرحمة",
            status: .pending,
            fulfillmentType: .delivery,
            date: Calendar.current.date(byAdding: .hour, value: -2, to: .now)!,
            totalPrice: 180, itemCount: 3
        ),
        OrderPresentationModel(
            id: 1230, orderNumber: 1230,
            pharmacyName: "صيدلية الشفاء",
            status: .delivered,
            fulfillmentType: .pickup,
            date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            totalPrice: 125, itemCount: 2
        ),
        OrderPresentationModel(
            id: 1205, orderNumber: 1205,
            pharmacyName: "صيدلية العزيز",
            status: .delivered,
            fulfillmentType: .delivery,
            date: Calendar.current.date(byAdding: .day, value: -20, to: .now)!,
            totalPrice: 240, itemCount: 4
        ),
        OrderPresentationModel(
            id: 1180, orderNumber: 1180,
            pharmacyName: "صيدلية النيل",
            status: .cancelled,
            fulfillmentType: .pickup,
            date: Calendar.current.date(byAdding: .day, value: -23, to: .now)!,
            totalPrice: 0, itemCount: 2
        ),
    ]
}

extension OrderDetailPresentationModel {
    static let mock = OrderDetailPresentationModel(
        id: 1258, orderNumber: 1258,
        pharmacyName: "صيدلية الرحمة",
        pharmacyId: 1,
        status: .pending,
        fulfillmentType: .delivery,
        date: Calendar.current.date(byAdding: .hour, value: -2, to: .now)!,
        items: [
            OrderDetailItemModel(id: 1, productName: "Panadol 500mg", originalProductName: nil, quantity: 2, unitPrice: 45),
            OrderDetailItemModel(id: 2, productName: "Vitamin C 1000mg", originalProductName: "Vitamin C 500mg", quantity: 1, unitPrice: 90),
        ],
        itemsSubtotal: 180,
        deliveryFee: 25,
        totalPrice: 180
    )
}
