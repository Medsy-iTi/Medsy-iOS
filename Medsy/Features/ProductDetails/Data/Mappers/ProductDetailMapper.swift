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
            arabicName: dto.arabicName ?? dto.name,
            scientificName: dto.scientificName ?? "",
            price: dto.price,
            imageUrl: dto.imageUrl,
            categoryId: dto.categoryId ?? 0,
            categoryName: dto.categoryName ?? "",
            company: dto.company ?? "",
            route: dto.route ?? "",
            isPrescription: dto.isPrescription ?? false,
            descriptionText: dto.description ?? "",
            productName: dto.productName ?? "",
            strength: dto.strength ?? "",
            packSize: dto.packSize ?? "",
            form: dto.form ?? dto.dosageForm ?? "",
            scientificCategory: dto.scientificCategory ?? "",
            consumerCategory: dto.consumerCategory ?? ""
        )
    }
}
