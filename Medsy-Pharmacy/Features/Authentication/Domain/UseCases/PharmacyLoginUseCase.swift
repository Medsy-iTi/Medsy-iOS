//  PharmacyLoginUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 17/07/2026.
//

protocol PharmacyLoginUseCaseProtocol {
    func execute(input: PharmacyLoginInput) async throws -> PharmacyAuthenticatedSession
}

final class PharmacyLoginUseCase: PharmacyLoginUseCaseProtocol {
    private let repository: PharmacyAuthenticationRepositoryProtocol
    private let tokenStore: TokenStoreProtocol

    init(
        repository: PharmacyAuthenticationRepositoryProtocol,
        tokenStore: TokenStoreProtocol
    ) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    func execute(input: PharmacyLoginInput) async throws -> PharmacyAuthenticatedSession {
        let session = try await repository.login(input: input)
        try tokenStore.save(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        return session
    }
}
