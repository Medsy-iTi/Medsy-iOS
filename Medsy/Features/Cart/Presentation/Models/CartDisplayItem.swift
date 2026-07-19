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

enum CartSampleData {
    static let items: [CartDisplayItem] = [
        CartDisplayItem(
            id: "1",
            productID: 1,
            cartItemID: nil,
            name: "Panadol Extra",
            dosageInfo: "20 tablets",
            unitPrice: 45,
            quantity: 2,
            imageUrl: nil
        ),
        CartDisplayItem(
            id: "2",
            productID: 2,
            cartItemID: nil,
            name: "Augmentin",
            dosageInfo: "1 g • 14 tablets",
            unitPrice: 180,
            quantity: 1,
            imageUrl: nil
        ),
        CartDisplayItem(
            id: "3",
            productID: 3,
            cartItemID: nil,
            name: "Telfast",
            dosageInfo: "120 mg • 10 tablets",
            unitPrice: 95,
            quantity: 1,
            imageUrl: nil
        )
    ]
}
