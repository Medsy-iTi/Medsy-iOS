//
//  LogoutUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol LogoutUseCaseProtocol {
    func execute()
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let tokenStore: TokenStoreProtocol

    init(tokenStore: TokenStoreProtocol) {
        self.tokenStore = tokenStore
    }

    func execute() {
        try? tokenStore.clearTokens()
    }
}
