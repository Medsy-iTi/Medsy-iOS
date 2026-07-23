//
//  MedicineAnalyzeRemoteDataSource.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation

protocol MedicineAnalyzeRemoteDataSourceProtocol {
    func analyze(imageData: Data, language: String) async throws -> [MedicineImageProductDTO]
}

final class MedicineAnalyzeRemoteDataSource: MedicineAnalyzeRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func analyze(imageData: Data, language: String) async throws -> [MedicineImageProductDTO] {
        let response: MedicineImageAnalysisResponseDTO = try await networkService.request(
            endpoint: MedicineAnalyzeEndpoint.analyze(
                imageData: imageData,
                language: language
            )
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let products = response.data else {
            throw NetworkError.decodingFailed
        }
        return products
    }
}
