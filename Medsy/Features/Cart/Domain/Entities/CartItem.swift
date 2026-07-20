//
//  CartItem.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

struct CartItem: Identifiable, Equatable {
    let id: Int64
    let productID: Int64
    let productName: String
    let dosageInfo: String
    let imageURL: String?
    let unitPrice: Double
    let quantity: Int
    let subtotal: Double

    init(
        id: Int64,
        productID: Int64,
        productName: String,
        dosageInfo: String = "",
        imageURL: String?,
        unitPrice: Double,
        quantity: Int,
        subtotal: Double? = nil
    ) {
        self.id = id
        self.productID = productID
        self.productName = productName
        self.dosageInfo = dosageInfo
        self.imageURL = imageURL
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.subtotal = subtotal ?? unitPrice * Double(quantity)
    }
}

struct AddCartItemInput: Equatable {
    let productID: Int64
    let quantity: Int
    let dosageInfo: String

    init(productID: Int64, quantity: Int, dosageInfo: String = "") {
        self.productID = productID
        self.quantity = quantity
        self.dosageInfo = dosageInfo
    }
}
