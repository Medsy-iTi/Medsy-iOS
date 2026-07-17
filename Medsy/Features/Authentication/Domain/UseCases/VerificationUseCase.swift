//
//  VerificationUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol VerificationUseCaseProtocol {
    func execute(input: VerificationInput) async throws -> AuthenticatedSession
}

final class VerificationUseCase: VerificationUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStore: TokenStoreProtocol

    init(repository: AuthRepositoryProtocol, tokenStore: TokenStoreProtocol) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    func execute(input: VerificationInput) async throws -> AuthenticatedSession {
        let session = try await repository.verify(input: input)
        try tokenStore.save(accessToken: session.accessToken, refreshToken: session.refreshToken)
        return session
    }
}
