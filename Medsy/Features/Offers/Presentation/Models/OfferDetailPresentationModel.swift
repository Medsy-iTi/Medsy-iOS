//  OfferDetailPresentationModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation

struct OfferMedicineItem: Identifiable, Hashable {
    let id: String
    let name: String
    let dosage: String
    let price: Int
    let isAvailable: Bool
    let imageName: String
}

struct OfferDetailPresentationModel: Identifiable, Hashable {
    let id: String
    let pharmacyName: String
    let managerName: String
    let medicines: [OfferMedicineItem]
    let pharmacistComment: String
    let totalPrice: Int
}
