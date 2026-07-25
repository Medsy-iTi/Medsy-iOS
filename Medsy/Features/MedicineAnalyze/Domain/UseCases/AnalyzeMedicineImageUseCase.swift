//
//  AnalyzeMedicineImageUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation

protocol AnalyzeMedicineImageUseCaseProtocol {
    func execute(imageData: Data, language: String) async throws -> [AnalyzedMedicineProduct]
}

final class AnalyzeMedicineImageUseCase: AnalyzeMedicineImageUseCaseProtocol {
    private let repository: MedicineAnalyzeRepositoryProtocol

    init(repository: MedicineAnalyzeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(imageData: Data, language: String) async throws -> [AnalyzedMedicineProduct] {
        try await repository.analyze(imageData: imageData, language: language)
    }
}
