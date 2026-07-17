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
}
