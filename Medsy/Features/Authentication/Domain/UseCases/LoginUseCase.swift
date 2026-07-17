//
//  LoginUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol LoginUseCaseProtocol {
    func execute(input: LoginInput) async throws -> AuthenticatedSession
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStore: TokenStoreProtocol

    init(repository: AuthRepositoryProtocol, tokenStore: TokenStoreProtocol) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    func execute(input: LoginInput) async throws -> AuthenticatedSession {
        let session = try await repository.login(input: input)
        try tokenStore.save(accessToken: session.accessToken, refreshToken: session.refreshToken)
        return session
    }
}
