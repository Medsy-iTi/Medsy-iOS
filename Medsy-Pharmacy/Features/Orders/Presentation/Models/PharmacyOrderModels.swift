//
//  PharmacyOrderModels.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import Foundation

enum PharmacyOrdersFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case new
    case preparing
    case delivered

    var id: String { rawValue }
}

enum PharmacyOrderListStatus: Equatable, Sendable {
    case new
    case preparing
    case delivered
    case completed
    case expired
}

enum PharmacyOrderPaymentMethod: Equatable, Sendable {
    case cash
    case visa(lastFourDigits: String)
}

struct PharmacyOrderListItem: Identifiable, Equatable, Sendable {
    let id: String
    let customerName: String
    let phoneNumber: String
    let address: String
    let paymentMethod: PharmacyOrderPaymentMethod
    let amount: Int
    let minutesAgo: Int
    let status: PharmacyOrderListStatus
}
