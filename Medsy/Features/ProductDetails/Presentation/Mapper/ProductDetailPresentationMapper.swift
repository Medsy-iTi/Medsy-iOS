//
//  ProductDetailPresentationMapper.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

enum ProductDetailPresentationMapper {

    static func map(_ entity: ProductDetailEntity, isRTL: Bool) -> ProductDetailDisplayModel {


        var rows: [ProductInfoRow] = []

        if !entity.company.isEmpty {
            rows.append(ProductInfoRow(
                icon: "flask",
                label: "product.manufacturer",
                value: entity.company
            ))
        }

        if !entity.scientificName.isEmpty {
            rows.append(ProductInfoRow(
                icon: "pencil.and.outline",
                label: "product.scientific_name",
                value: entity.scientificName
            ))
        }

        if !entity.categoryName.isEmpty {
            rows.append(ProductInfoRow(
                icon: "shippingbox",
                label: "product.category",
                value: entity.categoryName
            ))
        }

        if !entity.route.isEmpty {
            rows.append(ProductInfoRow(
                icon: "arrow.right.circle",
                label: "product.route",
                value: entity.route
            ))
        }

        if !entity.form.isEmpty {
            rows.append(ProductInfoRow(
                icon: "pills",
                label: "product.form",
                value: entity.form
            ))
        }

       /* if !entity.strength.isEmpty {
            rows.append(ProductInfoRow(
                icon: "bolt",
                label: "product.strength",
                value: entity.strength
            ))
        }

        if !entity.packSize.isEmpty {
            rows.append(ProductInfoRow(
                icon: "number.square",
                label: "product.pack_size",
                value: entity.packSize
            ))
        }
*/
        if !entity.scientificCategory.isEmpty {
            rows.append(ProductInfoRow(
                icon: "book.circle",
                label: "product.scientific_category",
                value: entity.scientificCategory
            ))
        }

        if !entity.consumerCategory.isEmpty {
            rows.append(ProductInfoRow(
                icon: "tag",
                label: "product.consumer_category",
                value: entity.consumerCategory
            ))
        }

        if entity.isPrescription {
            rows.append(ProductInfoRow(
                icon: "lock",
                label: "product.dispense_method",
                value: "product.dispense_method_value".localized,
                valueColor: .danger
            ))
        }

        let images: [String] = entity.imageUrl.map { [$0] } ?? []

        let (englishShortName, dosage) = ProductNameParser.parseName(entity.name)

        let displayName: String
        if !entity.productName.isEmpty {
            displayName = entity.productName
        } else if isRTL && !entity.arabicName.isEmpty && entity.arabicName != entity.name {
            displayName = entity.arabicName
        } else {
            displayName = englishShortName
        }

        return ProductDetailDisplayModel(
            id: String(entity.id),
            images: images,
            title: displayName,
            subtitle: dosage,
            price: entity.price,
            currencyKey: "currency.egp",
            requiresPharmacistReview: entity.isPrescription,
            descriptionText: entity.descriptionText,
            infoRows: rows
        )
    }
}
