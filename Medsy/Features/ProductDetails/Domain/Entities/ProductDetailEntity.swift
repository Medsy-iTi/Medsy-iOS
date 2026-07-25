//
//  ProductDetailEntity.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//

import Foundation


struct ProductDetailEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let arabicName: String
    let scientificName: String
    let price: Double
    let imageUrl: String?
    let categoryName: String
    let company: String
    let route: String
    let isPrescription: Bool
    let descriptionText: String
    let productName: String
    let strength: String
    let packSize: String
    let form: String
    let scientificCategory: String
    let consumerCategory: String
}
