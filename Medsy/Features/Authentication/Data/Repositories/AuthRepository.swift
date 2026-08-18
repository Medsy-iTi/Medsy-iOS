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

    func login(input: LoginInput) async throws -> AuthenticatedSession {
        let session = try await networkDataSource.login(request: LoginRequestDTO(input: input))
        return session.toDomain()
    }

    func register(input: SignupInput) async throws {
        try await networkDataSource.register(request: SignupRequestDTO(input: input))
    }

    func verify(input: VerificationInput) async throws -> AuthenticatedSession {
        let session = try await networkDataSource.verify(request: VerificationRequestDTO(input: input))
        return session.toDomain()
    }

    func logout(refreshToken: String) async throws {
        try await networkDataSource.logout(request: LogoutRequestDTO(refreshToken: refreshToken))
    }

    func requestPasswordReset(input: ForgotPasswordInput) async throws {
        try await networkDataSource.requestPasswordReset(
            request: ForgotPasswordRequestDTO(input: input)
        )
    }

    func verifyPasswordReset(
        input: VerifyPasswordResetInput
    ) async throws -> PasswordResetAuthorization {
        let authorization = try await networkDataSource.verifyPasswordReset(
            request: VerifyPasswordResetRequestDTO(input: input)
        )
        return authorization.toDomain()
    }

    func resetPassword(input: ResetPasswordInput) async throws {
        try await networkDataSource.resetPassword(
            request: ResetPasswordRequestDTO(input: input)
        )
    }
}
