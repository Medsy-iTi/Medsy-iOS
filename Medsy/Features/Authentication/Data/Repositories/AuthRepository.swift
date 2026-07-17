//
//  AuthRepository.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

final class AuthRepository: AuthRepositoryProtocol {
    private let networkDataSource: AuthNetworkDataSourceProtocol

    init(networkDataSource: AuthNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }

    func register(input: SignupInput) async throws {
        try await networkDataSource.register(request: SignupRequestDTO(input: input))
    }

    func verify(input: VerificationInput) async throws -> AuthenticatedSession {
        let session = try await networkDataSource.verify(request: VerificationRequestDTO(input: input))
        return session.toDomain()
    }
}
