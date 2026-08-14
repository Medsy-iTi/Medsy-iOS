//
//  FavoriteMedicineMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

enum FavoriteMedicineMapper {
    static func map(_ medicine: FavoriteMedicine) -> FavoriteMedicineRecord {
        FavoriteMedicineRecord(
            productID: medicine.id,
            name: medicine.name,
            arabicName: medicine.arabicName,
            scientificName: medicine.scientificName,
            price: medicine.price,
            imageURL: medicine.imageURL,
            categoryID: medicine.categoryID,
            categoryName: medicine.categoryName,
            company: medicine.company,
            route: medicine.route,
            createdAt: medicine.createdAt
        )
    }

    static func map(_ record: FavoriteMedicineRecord) -> FavoriteMedicine {
        FavoriteMedicine(
            id: record.productID,
            name: record.name,
            arabicName: record.arabicName,
            scientificName: record.scientificName,
            price: record.price,
            imageURL: record.imageURL,
            categoryID: record.categoryID,
            categoryName: record.categoryName,
            company: record.company,
            route: record.route,
            createdAt: record.createdAt
        )
    }
}
