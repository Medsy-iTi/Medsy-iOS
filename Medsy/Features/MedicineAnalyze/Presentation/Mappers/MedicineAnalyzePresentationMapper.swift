//
//  MedicineAnalyzePresentationMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

enum MedicineAnalyzePresentationMapper {
    static func map(_ product: AnalyzedMedicineProduct) -> MedicineAnalyzeProductDisplay {
        MedicineAnalyzeProductDisplay(
            id: String(product.id),
            name: product.name,
            productName: product.productName,
            strength: product.strength,
            packSize: product.packSize,
            form: product.form,
            price: product.price,
            scientificName: product.scientificName,
            scientificCategory: product.scientificCategory,
            consumerCategory: product.consumerCategory,
            company: product.company,
            description: product.description,
            imageURL: product.imageURL
        )
    }
}
