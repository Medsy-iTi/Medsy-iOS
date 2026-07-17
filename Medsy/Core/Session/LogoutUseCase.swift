//
//  LogoutUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol LogoutUseCaseProtocol {
    func execute() async
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStore: TokenStoreProtocol

    init(repository: AuthRepositoryProtocol, tokenStore: TokenStoreProtocol) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    func execute() async {
        guard let refreshToken = tokenStore.refreshToken(), !refreshToken.isEmpty else {
            try? tokenStore.clearTokens()
            return
        }

        defer { try? tokenStore.clearTokens() }
        try? await repository.logout(refreshToken: refreshToken)
    }
}
