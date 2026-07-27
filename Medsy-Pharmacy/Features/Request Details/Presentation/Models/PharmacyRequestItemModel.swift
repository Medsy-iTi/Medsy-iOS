//
//  PharmacyRequestItemModel.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyOrderItem: Identifiable {
    let id: String
    let requestItemId: Int
    let productId: Int
    let name: String
    let spec: String
    let quantity: Int
    var price: Double
    let imageName: String?
    let imageUrl: String?
    var isAvailable: Bool = true
    var selectedOfferProductId: Int
    var alternativeMedicine: String? = nil
    let form: String?
    let strength: String?
    let packSize: String?

    init(
        id: String,
        requestItemId: Int = 0,
        productId: Int = 0,
        name: String,
        spec: String,
        quantity: Int,
        price: Double,
        imageName: String? = nil,
        imageUrl: String? = nil,
        isAvailable: Bool = true,
        selectedOfferProductId: Int? = nil,
        alternativeMedicine: String? = nil,
        form: String? = nil,
        strength: String? = nil,
        packSize: String? = nil
    ) {
        self.id = id
        self.requestItemId = requestItemId != 0 ? requestItemId : (Int(id) ?? 0)
        self.productId = productId
        self.name = name
        self.spec = spec
        self.quantity = quantity
        self.price = price
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.isAvailable = isAvailable
        self.selectedOfferProductId = selectedOfferProductId ?? productId
        self.alternativeMedicine = alternativeMedicine
        self.form = form
        self.strength = strength
        self.packSize = packSize
    }
}

struct PharmacyCustomerInfo {
    let name: String
    let phone: String
    let address: String
}

struct PharmacyRequestDetailsModel {
    let id: String
    let minutesAgo: Int
    let statusTitle: String
    let customer: PharmacyCustomerInfo
    var items: [PharmacyOrderItem]
    let deliveryFee: Double
    let notes: String
    var prescriptionImageUrl: String? = nil
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let createdAt: Date

    init(
        id: String,
        minutesAgo: Int = 0,
        statusTitle: String,
        customer: PharmacyCustomerInfo,
        items: [PharmacyOrderItem],
        deliveryFee: Double,
        notes: String,
        prescriptionImageUrl: String? = nil,
        deliveryLatitude: Double? = nil,
        deliveryLongitude: Double? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.minutesAgo = minutesAgo
        self.statusTitle = statusTitle
        self.customer = customer
        self.items = items.isEmpty ? [
            PharmacyOrderItem(id: "1", name: "pharmacy.request.product_label".localized("1"), spec: "1", quantity: 1, price: 0.0, imageName: nil),
            PharmacyOrderItem(id: "2", name: "pharmacy.request.product_label".localized("2"), spec: "1", quantity: 1, price: 0.0, imageName: nil)
        ] : items
        self.deliveryFee = deliveryFee
        self.notes = notes
        self.prescriptionImageUrl = prescriptionImageUrl
        self.deliveryLatitude = deliveryLatitude
        self.deliveryLongitude = deliveryLongitude
        self.createdAt = createdAt ?? Date(timeIntervalSinceNow: -Double(minutesAgo * 60))
    }
    
    var subtotal: Double {
        items.filter { $0.isAvailable }.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var total: Double {
        subtotal + deliveryFee
    }
}

extension PharmacyRequestDetailsModel {
    init(order: PharmacyOrderListItem) {
        self.init(
            id: order.id,
            minutesAgo: Int(Date().timeIntervalSince(order.createdAt) / 60),
            statusTitle: order.status == .new ? "pharmacy.home.order_new".localized : (order.status == .preparing ? "pharmacy.home.order_preparing".localized : "pharmacy.home.order_delivered".localized),
            customer: PharmacyCustomerInfo(
                name: order.customerName,
                phone: order.phoneNumber,
                address: order.address
            ),
            items: [
                PharmacyOrderItem(id: "1", name: "pharmacy.request.product_label".localized("1"), spec: "1", quantity: 1, price: 0.0, imageName: nil),
                PharmacyOrderItem(id: "2", name: "pharmacy.request.product_label".localized("2"), spec: "1", quantity: 1, price: 0.0, imageName: nil)
            ],
            deliveryFee: 0.0,
            notes: "",
            deliveryLatitude: nil,
            deliveryLongitude: nil,
            createdAt: order.createdAt
        )
    }

    init(order: PharmacyOrder) {
        let mappedItems = order.items.isEmpty ? [
            PharmacyOrderItem(id: "1", name: "pharmacy.request.product_label".localized("1"), spec: "1", quantity: 1, price: 0.0, imageName: nil),
            PharmacyOrderItem(id: "2", name: "pharmacy.request.product_label".localized("2"), spec: "1", quantity: 1, price: 0.0, imageName: nil)
        ] : order.items.map { item in
            PharmacyOrderItem(
                id: String(item.id),
                name: "pharmacy.request.product_label".localized(String(item.productId)),
                spec: "\(item.quantity)",
                quantity: item.quantity,
                price: item.unitPrice,
                imageName: nil,
                form: item.form,
                strength: item.strength,
                packSize: item.packSize
            )
        }

        self.init(
            id: String(order.id),
            minutesAgo: 0,
            statusTitle: order.status == .pending ? "pharmacy.home.order_new".localized : (order.status == .delivered ? "pharmacy.home.order_delivered".localized : "pharmacy.home.order_preparing".localized),
            customer: PharmacyCustomerInfo(
                name: order.customerName ?? "pharmacy.request.customer_id_label".localized(String(order.userId)),
                phone: order.customerPhone ?? "—",
                address: order.deliveryAddress.isEmpty ? "pharmacy.orders.address.fallback".localized : order.deliveryAddress
            ),
            items: mappedItems,
            deliveryFee: 0.0,
            notes: order.notes ?? "",
            deliveryLatitude: order.deliveryCoordinate.latitude,
            deliveryLongitude: order.deliveryCoordinate.longitude,
            createdAt: order.date
        )
    }

    init(homeOrder: PharmacyHomeOrder) {
        self.init(
            id: homeOrder.id,
            minutesAgo: homeOrder.minutesAgo,
            statusTitle: homeOrder.status.titleKey.localized,
            customer: PharmacyCustomerInfo(
                name: homeOrder.customerNameKey.localized,
                phone: "010 1234 5678",
                address: homeOrder.addressKey.localized
            ),
            items: [
                PharmacyOrderItem(id: "1", name: "pharmacy.request.product_label".localized("1"), spec: "1", quantity: 1, price: 0.0, imageName: nil),
                PharmacyOrderItem(id: "2", name: "pharmacy.request.product_label".localized("2"), spec: "1", quantity: 1, price: 0.0, imageName: nil)
            ],
            deliveryFee: 0.0,
            notes: "",
            deliveryLatitude: nil,
            deliveryLongitude: nil,
            createdAt: Date(timeIntervalSinceNow: -Double(homeOrder.minutesAgo * 60))
        )
    }
}
