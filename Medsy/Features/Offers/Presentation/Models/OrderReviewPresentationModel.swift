//  OrderReviewPresentationModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation

struct OrderReviewPresentationModel: Identifiable, Hashable {
    let id: String
    let pharmacyName: String
    let managerName: String
    let medicines: [OfferMedicineItem]
    let deliveryAddress: String
    let deliveryFee: Int
    let medicinesSubtotal: Int
    let totalPrice: Int
}
