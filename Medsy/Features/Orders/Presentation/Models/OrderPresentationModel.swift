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
    let itemImageURLs: [String]
    let pharmacyNames: [String]

    init(
        id: Int,
        orderNumber: Int,
        pharmacyName: String,
        status: OrderStatusPresentation,
        fulfillmentType: OrderFulfillmentType,
        date: Date,
        totalPrice: Double,
        itemCount: Int,
        itemImageURLs: [String],
        pharmacyNames: [String] = []
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.pharmacyName = pharmacyName
        self.status = status
        self.fulfillmentType = fulfillmentType
        self.date = date
        self.totalPrice = totalPrice
        self.itemCount = itemCount
        self.itemImageURLs = itemImageURLs
        self.pharmacyNames = pharmacyNames
    }
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
    let pharmacies: [OrderPharmacyPresentationModel]
    let requestID: Int?
    let paymentMethod: OrderPaymentMethod?
    let paymentStatus: OrderPaymentStatus?
    let paymentExpiresAt: Date?
    let paidAt: Date?

    init(
        id: Int,
        orderNumber: Int,
        pharmacyName: String,
        pharmacyId: Int,
        status: OrderStatusPresentation,
        fulfillmentType: OrderFulfillmentType,
        date: Date,
        items: [OrderDetailItemModel],
        itemsSubtotal: Double,
        deliveryFee: Double?,
        totalPrice: Double,
        pharmacies: [OrderPharmacyPresentationModel] = [],
        requestID: Int? = nil,
        paymentMethod: OrderPaymentMethod? = nil,
        paymentStatus: OrderPaymentStatus? = nil,
        paymentExpiresAt: Date? = nil,
        paidAt: Date? = nil
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.pharmacyName = pharmacyName
        self.pharmacyId = pharmacyId
        self.status = status
        self.fulfillmentType = fulfillmentType
        self.date = date
        self.items = items
        self.itemsSubtotal = itemsSubtotal
        self.deliveryFee = deliveryFee
        self.totalPrice = totalPrice
        self.pharmacies = pharmacies
        self.requestID = requestID
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
        self.paymentExpiresAt = paymentExpiresAt
        self.paidAt = paidAt
    }
}

struct OrderPharmacyPresentationModel: Identifiable, Equatable {
    let id: Int
    let pharmacyId: Int
    let name: String
    let coordinate: OrderCoordinatePresentation?
    let items: [OrderDetailItemModel]

    var subtotal: Double {
        items.reduce(0) { $0 + ($1.unitPrice * Double($1.quantity)) }
    }
}

struct OrderCoordinatePresentation: Equatable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double
}

enum OrderRoutePresentationState: Equatable {
    case idle
    case locating
    case routing
    case ready(points: [OrderCoordinatePresentation])
    case permissionDenied
    case locationUnavailable
    case routeUnavailable
}

struct OrderDetailItemModel: Identifiable, Equatable {
    let id: Int
    let productId: Int?
    let productName: String
    let originalProductName: String?
    let quantity: Int
    let unitPrice: Double
    let imageURL: String?
}


extension OrderPresentationModel {
    var displayedPharmacyNames: [String] {
        pharmacyNames.isEmpty ? [pharmacyName].filter { !$0.isEmpty } : pharmacyNames
    }

    static let mockOrders: [OrderPresentationModel] = [
        OrderPresentationModel(
            id: 1258, orderNumber: 1258,
            pharmacyName: "صيدلية الرحمة",
            status: .pending,
            fulfillmentType: .delivery,
            date: Calendar.current.date(byAdding: .hour, value: -2, to: .now)!,
            totalPrice: 180,
            itemCount: 3,
            itemImageURLs: []
        ),
        OrderPresentationModel(
            id: 1230, orderNumber: 1230,
            pharmacyName: "صيدلية الشفاء",
            status: .delivered,
            fulfillmentType: .pickup,
            date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            totalPrice: 125,
            itemCount: 2,
            itemImageURLs: []
        ),
        OrderPresentationModel(
            id: 1205, orderNumber: 1205,
            pharmacyName: "صيدلية العزيز",
            status: .delivered,
            fulfillmentType: .delivery,
            date: Calendar.current.date(byAdding: .day, value: -20, to: .now)!,
            totalPrice: 240,
            itemCount: 4,
            itemImageURLs: []
        ),
        OrderPresentationModel(
            id: 1180, orderNumber: 1180,
            pharmacyName: "صيدلية النيل",
            status: .cancelled,
            fulfillmentType: .pickup,
            date: Calendar.current.date(byAdding: .day, value: -23, to: .now)!,
            totalPrice: 0,
            itemCount: 2,
            itemImageURLs: []
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
            OrderDetailItemModel(id: 1, productId: 101, productName: "Panadol 500mg", originalProductName: nil, quantity: 2, unitPrice: 45, imageURL: nil),
            OrderDetailItemModel(id: 2, productId: 102, productName: "Vitamin C 1000mg", originalProductName: "Vitamin C 500mg", quantity: 1, unitPrice: 90, imageURL: nil),
        ],
        itemsSubtotal: 180,
        deliveryFee: 25,
        totalPrice: 205,
        pharmacies: [
            OrderPharmacyPresentationModel(
                id: 71,
                pharmacyId: 1,
                name: "Al Rahma Pharmacy",
                coordinate: OrderCoordinatePresentation(latitude: 30.0444, longitude: 31.2357),
                items: [
                    OrderDetailItemModel(id: 1, productId: 101, productName: "Panadol 500mg", originalProductName: nil, quantity: 2, unitPrice: 45, imageURL: nil)
                ]
            ),
            OrderPharmacyPresentationModel(
                id: 72,
                pharmacyId: 2,
                name: "Al Shifa Pharmacy",
                coordinate: OrderCoordinatePresentation(latitude: 30.0520, longitude: 31.2300),
                items: [
                    OrderDetailItemModel(id: 2, productId: 102, productName: "Vitamin C 1000mg", originalProductName: "Vitamin C 500mg", quantity: 1, unitPrice: 90, imageURL: nil)
                ]
            )
        ]
    )
}
