//
//  ProductMapper.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

enum ProductMapper {

    static func map(_ dto: ProductDTO) -> Product {
        Product(
            id: dto.id,
            name: dto.name,
            arabicName: dto.arabicName ?? dto.name,
            scientificName: dto.scientificName ?? "",
            price: dto.price,
            imageUrl: dto.imageUrl,
            categoryId: dto.categoryId ?? 0,
            categoryName: dto.categoryName ?? dto.consumerCategory ?? "",
            company: dto.company ?? "",
            route: dto.route ?? ""
        )
    }

    static func map(_ page: PageDTO<ProductDTO>) -> PagedResult<Product> {
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
