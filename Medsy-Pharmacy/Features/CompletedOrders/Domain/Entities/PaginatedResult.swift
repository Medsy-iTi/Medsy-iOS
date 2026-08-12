//
//  PaginatedResult.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//

import Foundation

struct PaginatedResult<Element> {
    let content: [Element]
    let pageNumber: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    let isLast: Bool

    static var empty: PaginatedResult<Element> {
        PaginatedResult(content: [], pageNumber: 0, pageSize: 0, totalElements: 0, totalPages: 0, isLast: true)
    }
}
