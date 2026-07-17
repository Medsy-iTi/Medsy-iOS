//
//  RefreshTokenRepository.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

final class RefreshTokenRepository: RefreshTokenRepositoryProtocol {
    private let networkDataSource: AuthRefreshNetworkDataSourceProtocol

    init(networkDataSource: AuthRefreshNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }

    func refresh(refreshToken: String) async throws -> AuthenticatedSession {
        let session = try await networkDataSource.refresh(request: RefreshTokenRequestDTO(refreshToken: refreshToken))
        return session.toDomain()
    }
}
