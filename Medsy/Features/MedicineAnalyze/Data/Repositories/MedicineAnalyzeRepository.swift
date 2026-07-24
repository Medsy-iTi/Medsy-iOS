//
//  MedicineAnalyzeRepository.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation

final class MedicineAnalyzeRepository: MedicineAnalyzeRepositoryProtocol {
    private let remoteDataSource: MedicineAnalyzeRemoteDataSourceProtocol

    init(remoteDataSource: MedicineAnalyzeRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func analyze(imageData: Data, language: String) async throws -> [AnalyzedMedicineProduct] {
        let products = try await remoteDataSource.analyze(
            imageData: imageData,
            language: language
        )
        return products.map(MedicineImageAnalysisMapper.map)
    }
}
