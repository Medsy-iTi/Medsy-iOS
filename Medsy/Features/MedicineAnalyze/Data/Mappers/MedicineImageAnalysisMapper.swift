//
//  MedicineImageAnalysisMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

enum MedicineImageAnalysisMapper {
    static func map(_ dto: MedicineImageProductDTO) -> AnalyzedMedicineProduct {
        AnalyzedMedicineProduct(
            id: dto.id,
            name: dto.name,
            productName: dto.productName,
            strength: dto.strength,
            packSize: dto.packSize,
            form: dto.form,
            price: dto.price,
            scientificName: dto.scientificName,
            scientificCategory: dto.scientificCategory,
            categoryID: dto.categoryId,
            consumerCategory: dto.consumerCategory,
            company: dto.company,
            route: dto.route,
            description: dto.description,
            imageURL: dto.imageUrl
        )
    }
}
