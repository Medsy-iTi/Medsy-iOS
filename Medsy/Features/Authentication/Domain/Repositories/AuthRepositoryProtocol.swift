//
//  AuthRepositoryProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol AuthRepositoryProtocol {
    func login(input: LoginInput) async throws -> AuthenticatedSession
    func register(input: SignupInput) async throws
    func verify(input: VerificationInput) async throws -> AuthenticatedSession
    func logout(refreshToken: String) async throws
}
