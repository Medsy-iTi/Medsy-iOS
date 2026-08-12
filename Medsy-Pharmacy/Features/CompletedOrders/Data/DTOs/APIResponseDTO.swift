//
//  APIResponseDTO.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import Foundation

struct APIResponseDTO<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}

struct PaginatedResponseDTO<Element: Decodable>: Decodable {
    let content: [Element]
    let pageNumber: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    let last: Bool
}
