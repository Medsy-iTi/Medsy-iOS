//
//  RefreshSessionUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol RefreshSessionUseCaseProtocol {
    func execute(refreshToken: String) async throws -> AuthenticatedSession
}

final class RefreshSessionUseCase: RefreshSessionUseCaseProtocol {
    private let repository: RefreshTokenRepositoryProtocol

    init(repository: RefreshTokenRepositoryProtocol) {
        self.repository = repository
    }

    func execute(refreshToken: String) async throws -> AuthenticatedSession {
        try await repository.refresh(refreshToken: refreshToken)
    }
}
