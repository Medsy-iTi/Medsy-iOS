//
//  PharmacyRefreshSessionUseCase.swift
//  Medsy-Pharmacy
//

protocol PharmacyRefreshSessionUseCaseProtocol {
    func execute(refreshToken: String) async throws -> PharmacyAuthenticatedSession
}

final class PharmacyRefreshSessionUseCase: PharmacyRefreshSessionUseCaseProtocol {
    private let repository: PharmacyAuthenticationRepositoryProtocol

    init(repository: PharmacyAuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(refreshToken: String) async throws -> PharmacyAuthenticatedSession {
        try await repository.refresh(refreshToken: refreshToken)
    }
}
