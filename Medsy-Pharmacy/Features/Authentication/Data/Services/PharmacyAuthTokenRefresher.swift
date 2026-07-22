//
//  PharmacyAuthTokenRefresher.swift
//  Medsy-Pharmacy
//

actor PharmacyAuthTokenRefresher: TokenRefreshing {
    private let refreshSessionUseCaseFactory: @Sendable () async -> PharmacyRefreshSessionUseCaseProtocol
    private let tokenStore: TokenStoreProtocol
    private var activeRefresh: Task<Void, Error>?

    init(refreshSessionUseCaseFactory: @escaping @Sendable () async -> PharmacyRefreshSessionUseCaseProtocol, tokenStore: TokenStoreProtocol) {
        self.refreshSessionUseCaseFactory = refreshSessionUseCaseFactory
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

            let useCase = await refreshSessionUseCaseFactory()
            let session = try await useCase.execute(refreshToken: refreshToken)
            try tokenStore.save(accessToken: session.accessToken, refreshToken: session.refreshToken)
        }
        activeRefresh = task

        defer { activeRefresh = nil }
        try await task.value
    }
}
