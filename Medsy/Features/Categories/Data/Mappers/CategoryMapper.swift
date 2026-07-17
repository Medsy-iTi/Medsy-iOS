//
//  CategoryMapper.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.
//

import Foundation

enum CategoryMapper {

    static func map(_ dto: CategoryDTO) -> Category {
        Category(
            id: dto.id,
            name: dto.name
        )
    }

    static func map(_ page: PageDTO<CategoryDTO>) -> PagedResult<Category> {
        PagedResult(
            items: page.content.map(map),
            page: page.number ?? 0,
            size: page.size ?? page.content.count,
            totalElements: page.totalElements,
            totalPages: page.totalPages,
            isLast: page.last
        )
    }
}
