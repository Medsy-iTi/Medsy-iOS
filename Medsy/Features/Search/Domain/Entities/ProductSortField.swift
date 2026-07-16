//
//  ProductSortField.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//


import Foundation

enum ProductSortField: String {
    case id
    case name
    case arabicName
    case scientificName
    case price
    case company
    case route
}

enum SortDirection: String {
    case asc
    case desc
}

struct ProductSort: Equatable {
    let field: ProductSortField
    let direction: SortDirection

   
    var queryValue: String {
        "\(field.rawValue),\(direction.rawValue)"
    }
}
