//  PharmacyRequestItemModel.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 19/07/2026.
//

import SwiftUI

struct PharmacyOrderItem: Identifiable {
    let id: String
    let name: String
    let spec: String
    let quantity: Int
    let price: Double
    let imageName: String?
    var isAvailable: Bool = true
    var alternativeMedicine: String? = nil
}

struct PharmacyCustomerInfo {
    let name: String
    let phone: String
    let address: String
}

struct PharmacyRequestDetailsModel {
    let id: String
    let statusTitle: String
    let customer: PharmacyCustomerInfo
    var items: [PharmacyOrderItem]
    let deliveryFee: Double
    let notes: String
    
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var total: Double {
        subtotal + deliveryFee
    }
}
