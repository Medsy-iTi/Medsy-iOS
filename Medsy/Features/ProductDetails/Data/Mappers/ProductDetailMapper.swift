//
//  ProductDetailMapper.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//


import Foundation

enum ProductDetailMapper {

    static func map(_ dto: ProductDTO) -> ProductDetailEntity {
        ProductDetailEntity(
            id: dto.id,
            name: dto.name,
            scientificName: dto.scientificName ?? "",
            price: dto.price,
            imageUrl: dto.imageUrl,
            categoryName: dto.categoryName ?? "",
            company: dto.company ?? "",
            route: dto.route ?? "",
            isPrescription: dto.isPrescription ?? false,
            descriptionText: dto.description ?? ""
        )
    }
}
