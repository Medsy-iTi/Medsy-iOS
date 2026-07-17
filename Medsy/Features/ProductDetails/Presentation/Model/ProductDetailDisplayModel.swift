//
//  ProductDetailDisplayModel.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

struct ProductDetailDisplayModel: Identifiable {
    let id: String
    let images: [String]
    let title: String
    let subtitle: String
    let price: Double
    let currencyKey: String
    let requiresPharmacistReview: Bool
    let descriptionText: String
    let infoRows: [ProductInfoRow]
}
