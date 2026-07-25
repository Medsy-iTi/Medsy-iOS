//  OfferDetailPresentationModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation

    // OLD:
    // struct OfferMedicineItem: Identifiable, Hashable {
    //     let id: String
    //     let requestItemId: Int
    //     let name: String
    //     let dosage: String
    //     let price: Double
    //     let isAvailable: Bool
    //     let isAlternative: Bool
    //     let imageName: String
    //     let imageUrl: String?
    // }

struct OfferMedicineItem: Identifiable, Hashable {
    let id: String
    let requestItemId: Int
    let name: String
    let dosage: String
    let price: Double
    let isAvailable: Bool
    let isAlternative: Bool
    let imageName: String
    let imageUrl: String?
    var isSelected: Bool

    init(
        id: String,
        requestItemId: Int = 0,
        name: String,
        dosage: String,
        price: Double,
        isAvailable: Bool = true,
        isAlternative: Bool = false,
        imageName: String = "pill.fill",
        imageUrl: String? = nil,
        isSelected: Bool = true
    ) {
        self.id = id
        self.requestItemId = requestItemId
        self.name = name
        self.dosage = dosage
        self.price = price
        self.isAvailable = isAvailable
        self.isAlternative = isAlternative
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.isSelected = isAvailable ? isSelected : false
    }
}

struct OfferDetailPresentationModel: Identifiable, Hashable {
    let id: String
    let pharmacyName: String
    let managerName: String
    let medicines: [OfferMedicineItem]
    let pharmacistComment: String
    let totalPrice: Double
}

