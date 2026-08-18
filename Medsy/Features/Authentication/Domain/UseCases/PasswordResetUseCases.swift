//
//  PasswordResetUseCases.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

protocol ForgotPasswordUseCaseProtocol {
    func execute(input: ForgotPasswordInput) async throws
}

final class ForgotPasswordUseCase: ForgotPasswordUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: ForgotPasswordInput) async throws {
        try await repository.requestPasswordReset(input: input)
    }
}

protocol VerifyPasswordResetUseCaseProtocol {
    func execute(input: VerifyPasswordResetInput) async throws -> PasswordResetAuthorization
}

final class VerifyPasswordResetUseCase: VerifyPasswordResetUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: VerifyPasswordResetInput) async throws -> PasswordResetAuthorization {
        try await repository.verifyPasswordReset(input: input)
    }
}

protocol ResetPasswordUseCaseProtocol {
    func execute(input: ResetPasswordInput) async throws
}

final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: ResetPasswordInput) async throws {
        try await repository.resetPassword(input: input)
    }
}
