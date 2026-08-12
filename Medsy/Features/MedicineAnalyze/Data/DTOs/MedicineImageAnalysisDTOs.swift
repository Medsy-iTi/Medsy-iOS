//
//  MedicineImageAnalysisDTOs.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation

typealias MedicineImageAnalysisResponseDTO = APIResponseDTO<[MedicineImageProductDTO]>

struct MedicineImageProductDTO: Decodable {
    let id: Int
    let name: String
    let productName: String
    let strength: String?
    let packSize: String
    let form: String
    let price: Double
    let scientificName: String
    let scientificCategory: String
    let categoryId: Int
    let consumerCategory: String
    let company: String
    let route: String
    let description: String
    let imageUrl: String?
}
