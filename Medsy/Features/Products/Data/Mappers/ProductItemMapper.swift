//  ProductItemMapper.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

enum ProductItemMapper {
    static func map(_ dto: ProductDTO) -> ProductItem {
        ProductItem(
            id: dto.id,
            name: dto.name,
            arabicName: dto.arabicName ?? dto.name,
            scientificName: dto.scientificName ?? "",
            price: dto.price,
            imageUrl: dto.imageUrl,
            categoryId: dto.categoryId ?? 0,
            categoryName: dto.categoryName ?? "",
            company: dto.company ?? "",
            route: dto.route ?? ""
        )
    }

    static func map(_ page: PageDTO<ProductDTO>) -> PagedResult<ProductItem> {
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
