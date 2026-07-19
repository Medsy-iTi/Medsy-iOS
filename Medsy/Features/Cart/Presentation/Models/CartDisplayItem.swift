//
//  CartDisplayItem.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import Foundation

struct CartDisplayItem: Identifiable, Equatable {
    let id: String
    let productID: Int64?
    let cartItemID: Int64?
    let name: String
    let dosageInfo: String
    let unitPrice: Double
    let quantity: Int
    let imageUrl: String?

    init(
        id: String,
        productID: Int64? = nil,
        cartItemID: Int64? = nil,
        name: String,
        dosageInfo: String,
        unitPrice: Double,
        quantity: Int,
        imageUrl: String?
    ) {
        self.id = id
        self.productID = productID
        self.cartItemID = cartItemID
        self.name = name
        self.dosageInfo = dosageInfo
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.imageUrl = imageUrl
    }

    var lineTotal: Double {
        unitPrice * Double(quantity)
    }

    var duplicateIdentity: String {
        productID.map(String.init) ?? id
    }

    func updating(quantity: Int) -> CartDisplayItem {
        CartDisplayItem(
            id: id,
            productID: productID,
            cartItemID: cartItemID,
            name: name,
            dosageInfo: dosageInfo,
            unitPrice: unitPrice,
            quantity: quantity,
            imageUrl: imageUrl
        )
    }
}

enum CartViewState: Equatable {
    case loading
    case empty
    case loaded([CartDisplayItem])
    case error(String)
}
