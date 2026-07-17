//  PharmacyAuthRepository.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

final class PharmacyAuthRepository: PharmacyAuthRepositoryProtocol {
    private let networkDataSource: PharmacyAuthNetworkDataSourceProtocol

    init(networkDataSource: PharmacyAuthNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }

    func login(input: LoginInput) async throws -> AuthenticatedSession {
        let session = try await networkDataSource.login(request: LoginRequestDTO(input: input))
        return session.toDomain()
    }
}
