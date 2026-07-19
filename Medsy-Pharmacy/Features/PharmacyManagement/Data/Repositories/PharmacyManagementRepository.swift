//
//  PharmacyManagementRepository.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

final class PharmacyManagementRepository: PharmacyManagementRepositoryProtocol {
    private let remoteDataSource: PharmacyManagementRemoteDataSourceProtocol

    init(remoteDataSource: PharmacyManagementRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func getMyPharmacy() async throws -> ManagedPharmacy? {
        let pharmacy = try await remoteDataSource.getMyPharmacy()
        return pharmacy?.toDomain()
    }

    func createPharmacy(input: CreatePharmacyInput) async throws -> ManagedPharmacy {
        _ = try await remoteDataSource.createPharmacy(input: input)
        return try await refreshedPharmacy()
    }

    func updatePharmacy(input: UpdatePharmacyInput) async throws -> ManagedPharmacy {
        _ = try await remoteDataSource.updatePharmacy(input: input)
        return try await refreshedPharmacy()
    }

    func deletePharmacy(id: Int) async throws {
        try await remoteDataSource.deletePharmacy(id: id)
    }

    private func refreshedPharmacy() async throws -> ManagedPharmacy {
        guard let pharmacy = try await remoteDataSource.getMyPharmacy() else {
            throw NetworkError.decodingFailed
        }
        return pharmacy.toDomain()
    }
}
