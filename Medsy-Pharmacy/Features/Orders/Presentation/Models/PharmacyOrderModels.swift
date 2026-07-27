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
    case pendingApproval
    case expired
    case completed

    var id: String { rawValue }
}

enum PharmacyOrderListStatus: Equatable, Sendable {
    case new
    case preparing
    case delivered
    case completed
    case expired
    case pendingApproval
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
    let createdAt: Date
    let status: PharmacyOrderListStatus
}
