//
//  AnalyzedMedicineProduct.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation

struct AnalyzedMedicineProduct: Identifiable, Equatable {
    let id: Int
    let name: String
    let productName: String
    let strength: String?
    let packSize: String
    let form: String
    let price: Double
    let scientificName: String
    let scientificCategory: String
    let categoryID: Int
    let consumerCategory: String
    let company: String
    let route: String
    let description: String
    let imageURL: String?
}
