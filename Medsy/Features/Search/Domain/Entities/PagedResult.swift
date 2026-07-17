//
//  PagedResult.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

struct PagedResult<Item> {
    let items: [Item]
    let page: Int
    let size: Int
    let totalElements: Int?
    let totalPages: Int?
    let isLast: Bool?
}
