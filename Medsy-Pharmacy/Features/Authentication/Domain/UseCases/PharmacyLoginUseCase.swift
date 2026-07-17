//  PharmacyLoginUseCase.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

protocol PharmacyLoginUseCaseProtocol {
    func execute(input: LoginInput) async throws -> AuthenticatedSession
}

final class PharmacyLoginUseCase: PharmacyLoginUseCaseProtocol {
    private let repository: PharmacyAuthRepositoryProtocol
    private let tokenStore: TokenStoreProtocol

    init(repository: PharmacyAuthRepositoryProtocol, tokenStore: TokenStoreProtocol) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    func execute(input: LoginInput) async throws -> AuthenticatedSession {
        let session = try await repository.login(input: input)
        try tokenStore.save(accessToken: session.accessToken, refreshToken: session.refreshToken)
        return session
    }
}
