//
//  PharmacyVerificationUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol PharmacyVerificationUseCaseProtocol {
    func execute(input: PharmacyVerificationInput) async throws -> PharmacyAuthenticatedSession
}

final class PharmacyVerificationUseCase: PharmacyVerificationUseCaseProtocol {
    private let repository: PharmacyAuthenticationRepositoryProtocol
    private let tokenStore: TokenStoreProtocol

    init(
        repository: PharmacyAuthenticationRepositoryProtocol,
        tokenStore: TokenStoreProtocol
    ) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    func execute(input: PharmacyVerificationInput) async throws -> PharmacyAuthenticatedSession {
        let session = try await repository.verify(input: input)
        try tokenStore.save(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        return session
    }
}
