//
//  FavoriteMedicineDisplayModel.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation

struct FavoriteMedicineDisplayModel: Identifiable, Equatable {
    let id: String
    let title: String
    let dosageInfo: String
    let scientificName: String
    let company: String
    let price: Double
    let imageURL: String?
    let medicine: FavoriteMedicine

    var subtitle: String {
        scientificName.isEmpty ? company : scientificName
    }
}

enum FavoriteMedicinePresentationMapper {
    static func map(_ medicine: FavoriteMedicine, isRTL: Bool) -> FavoriteMedicineDisplayModel {
        let (englishShortName, dosage) = ProductNameParser.parseName(medicine.name)
        let title: String
        if isRTL, !medicine.arabicName.isEmpty, medicine.arabicName != medicine.name {
            title = medicine.arabicName
        } else {
            title = englishShortName
        }

        return FavoriteMedicineDisplayModel(
            id: String(medicine.id),
            title: title,
            dosageInfo: dosage,
            scientificName: medicine.scientificName,
            company: medicine.company,
            price: medicine.price,
            imageURL: medicine.imageURL,
            medicine: medicine
        )
    }
}

enum FavoriteCartItemPresentationMapper {
    static func map(_ product: FavoriteMedicineDisplayModel, quantity: Int = 1) -> CartDisplayItem {
        CartDisplayItem(
            id: product.id,
            productID: Int64(product.id),
            name: product.title,
            dosageInfo: product.dosageInfo,
            unitPrice: product.price,
            quantity: quantity,
            imageUrl: product.imageURL
        )
    }
}
