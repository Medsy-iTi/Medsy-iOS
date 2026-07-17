//
//  APIResponseDTO.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

struct APIResponseDTO<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}


struct PageDTO<T: Decodable>: Decodable {
    let content: [T]
    let totalElements: Int?
    let totalPages: Int?
    let number: Int?
    let size: Int?
    let last: Bool?
}

struct ProductDTO: Decodable {
    let id: Int
    let name: String
    let arabicName: String?
    let scientificName: String?
    let price: Double
    let imageUrl: String?
    let categoryId: Int?
    let categoryName: String?
    let company: String?
    let route: String?
}
