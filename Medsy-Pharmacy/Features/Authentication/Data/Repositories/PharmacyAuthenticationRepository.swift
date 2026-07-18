//
//  PharmacyAuthenticationRepository.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

final class PharmacyAuthenticationRepository: PharmacyAuthenticationRepositoryProtocol {
    private let remoteDataSource: PharmacyAuthenticationRemoteDataSourceProtocol

    init(remoteDataSource: PharmacyAuthenticationRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func login(input: PharmacyLoginInput) async throws -> PharmacyAuthenticatedSession {
        let session = try await remoteDataSource.login(
            request: PharmacyLoginRequestDTO(input: input)
        )
        return session.toDomain()
    }

    func register(input: PharmacyRegistrationInput) async throws {
        try await remoteDataSource.register(
            request: PharmacyRegistrationRequestDTO(input: input)
        )
    }

    func verify(input: PharmacyVerificationInput) async throws -> PharmacyAuthenticatedSession {
        let session = try await remoteDataSource.verify(
            request: PharmacyVerificationRequestDTO(input: input)
        )
        return session.toDomain()
    }
}
