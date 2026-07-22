//  OrderConfirmPresentationModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation

struct OrderConfirmPresentationModel: Identifiable, Hashable {
    let id: String
    let orderNumber: String
    let pharmacyName: String
    let managerName: String
    let deliveryAddress: String
    let estimatedTime: String
    let paymentMethod: String
}
