//
//  ConfirmOfferResult.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct ConfirmOfferOrder: Equatable, Hashable {
    let orderId: Int
    let pharmacyId: Int
    let pharmacyName: String
    let itemIds: [Int]
}

struct ConfirmOfferResult: Equatable, Hashable {
    let requestId: Int
    let orders: [ConfirmOfferOrder]
    let masterOrderId: Int?
    let orderStatus: MasterOrderStatus?
    let paymentMethod: MasterOrderPaymentMethod?
    let paymentStatus: MasterOrderPaymentStatus?

    init(
        requestId: Int,
        orders: [ConfirmOfferOrder],
        masterOrderId: Int? = nil,
        orderStatus: MasterOrderStatus? = nil,
        paymentMethod: MasterOrderPaymentMethod? = nil,
        paymentStatus: MasterOrderPaymentStatus? = nil
    ) {
        self.requestId = requestId
        self.orders = orders
        self.masterOrderId = masterOrderId
        self.orderStatus = orderStatus
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
    }
}
