//
//  AuthTokenRefresher.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

actor AuthTokenRefresher: TokenRefreshing {
    private let refreshSessionUseCase: RefreshSessionUseCaseProtocol
    private let tokenStore: TokenStoreProtocol
    private var activeRefresh: Task<Void, Error>?

    init(refreshSessionUseCase: RefreshSessionUseCaseProtocol, tokenStore: TokenStoreProtocol) {
        self.refreshSessionUseCase = refreshSessionUseCase
        self.tokenStore = tokenStore
    }

    func refreshTokens() async throws {
        if let activeRefresh {
            return try await activeRefresh.value
        }

        let task = Task {
            guard let refreshToken = tokenStore.refreshToken(), !refreshToken.isEmpty else {
                throw NetworkError.unauthorized
            }

            let session = try await refreshSessionUseCase.execute(refreshToken: refreshToken)
            try tokenStore.save(accessToken: session.accessToken, refreshToken: session.refreshToken)
        }
        activeRefresh = task

        defer { activeRefresh = nil }
        try await task.value
    }
}
