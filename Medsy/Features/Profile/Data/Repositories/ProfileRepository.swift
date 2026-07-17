//
//  ProfileRepository.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

final class ProfileRepository: ProfileRepositoryProtocol {
    private let remoteDataSource: ProfileRemoteDataSourceProtocol

    init(remoteDataSource: ProfileRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchProfile() async throws -> CustomerProfile {
        let profile = try await remoteDataSource.fetchProfile()
        return CustomerProfileMapper.map(profile)
    }

    func updateProfile(input: UpdateCustomerProfileInput) async throws -> CustomerProfile {
        let request = UpdateCustomerProfileRequestDTO(input: input)
        let profile = try await remoteDataSource.updateProfile(request: request)
        return CustomerProfileMapper.map(profile)
    }
}
