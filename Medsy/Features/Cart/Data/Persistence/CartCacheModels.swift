//
//  CartCacheModels.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation
import SwiftData

@Model
final class CachedCartModel {
    @Attribute(.unique) var accountIdentifier: String
    var cartID: Int64?
    var totalPrice: Double

    init(accountIdentifier: String, cartID: Int64?, totalPrice: Double) {
        self.accountIdentifier = accountIdentifier
        self.cartID = cartID
        self.totalPrice = totalPrice
    }
}

@Model
final class CachedCartItemModel {
    @Attribute(.unique) var cacheIdentifier: String
    var accountIdentifier: String
    var cartItemID: Int64
    var productID: Int64
    var productName: String
    var dosageInfo: String
    var imageURL: String?
    var unitPrice: Double
    var quantity: Int
    var subtotal: Double
    var sortOrder: Int

    init(
        cacheIdentifier: String,
        accountIdentifier: String,
        cartItemID: Int64,
        productID: Int64,
        productName: String,
        dosageInfo: String,
        imageURL: String?,
        unitPrice: Double,
        quantity: Int,
        subtotal: Double,
        sortOrder: Int
    ) {
        self.cacheIdentifier = cacheIdentifier
        self.accountIdentifier = accountIdentifier
        self.cartItemID = cartItemID
        self.productID = productID
        self.productName = productName
        self.dosageInfo = dosageInfo
        self.imageURL = imageURL
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.subtotal = subtotal
        self.sortOrder = sortOrder
    }
}

@Model
final class CachedCartPrescriptionModel {
    @Attribute(.unique) var cacheIdentifier: String
    var accountIdentifier: String
    var prescriptionID: UUID
    @Attribute(.externalStorage) var data: Data
    var source: String
    var createdAt: Date

    init(
        cacheIdentifier: String,
        accountIdentifier: String,
        prescriptionID: UUID,
        data: Data,
        source: String,
        createdAt: Date
    ) {
        self.cacheIdentifier = cacheIdentifier
        self.accountIdentifier = accountIdentifier
        self.prescriptionID = prescriptionID
        self.data = data
        self.source = source
        self.createdAt = createdAt
    }
}
