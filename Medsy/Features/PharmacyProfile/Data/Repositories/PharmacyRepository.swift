//
//  PharmacyRepository.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation

final class PharmacyRepository: PharmacyRepositoryProtocol {
    private let remoteDataSource: PharmacyRemoteDataSourceProtocol

    init(remoteDataSource: PharmacyRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchPharmacy(id: Int) async throws -> Pharmacy {
        let dto = try await remoteDataSource.fetchPharmacy(id: id)
        return PharmacyMapper.map(dto)
    }
}
