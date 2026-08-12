//
//  PharmacyRemoteDataSource.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation

protocol PharmacyRemoteDataSourceProtocol {
    func fetchPharmacy(id: Int) async throws -> PharmacyDataDTO
}

final class PharmacyRemoteDataSource: PharmacyRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchPharmacy(id: Int) async throws -> PharmacyDataDTO {
        let response: PharmacyResponseDTO = try await networkService.request(
            endpoint: PharmacyEndpoint.fetchPharmacy(id: id)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        return response.data
    }
}
