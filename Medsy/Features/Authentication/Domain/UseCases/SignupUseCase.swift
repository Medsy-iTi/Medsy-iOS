//
//  SignupUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol SignupUseCaseProtocol {
    func execute(input: SignupInput) async throws
}

final class SignupUseCase: SignupUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: SignupInput) async throws {
        try await repository.register(input: input)
    }
}
