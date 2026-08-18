//
//  PharmacyPasswordResetUseCases.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

protocol PharmacyForgotPasswordUseCaseProtocol {
    func execute(input: PharmacyForgotPasswordInput) async throws
}

final class PharmacyForgotPasswordUseCase: PharmacyForgotPasswordUseCaseProtocol {
    private let repository: PharmacyAuthenticationRepositoryProtocol

    init(repository: PharmacyAuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: PharmacyForgotPasswordInput) async throws {
        try await repository.requestPasswordReset(input: input)
    }
}

protocol PharmacyVerifyPasswordResetUseCaseProtocol {
    func execute(
        input: PharmacyVerifyPasswordResetInput
    ) async throws -> PharmacyPasswordResetAuthorization
}

final class PharmacyVerifyPasswordResetUseCase: PharmacyVerifyPasswordResetUseCaseProtocol {
    private let repository: PharmacyAuthenticationRepositoryProtocol

    init(repository: PharmacyAuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        input: PharmacyVerifyPasswordResetInput
    ) async throws -> PharmacyPasswordResetAuthorization {
        try await repository.verifyPasswordReset(input: input)
    }
}

protocol PharmacyResetPasswordUseCaseProtocol {
    func execute(input: PharmacyResetPasswordInput) async throws
}

final class PharmacyResetPasswordUseCase: PharmacyResetPasswordUseCaseProtocol {
    private let repository: PharmacyAuthenticationRepositoryProtocol

    init(repository: PharmacyAuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: PharmacyResetPasswordInput) async throws {
        try await repository.resetPassword(input: input)
    }
}
