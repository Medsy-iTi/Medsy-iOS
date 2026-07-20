//
//  PharmacyAuthenticationRepositoryProtocol.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol PharmacyAuthenticationRepositoryProtocol {
    func login(input: PharmacyLoginInput) async throws -> PharmacyAuthenticatedSession
    func register(input: PharmacyRegistrationInput) async throws
    func verify(input: PharmacyVerificationInput) async throws -> PharmacyAuthenticatedSession
    func refresh(refreshToken: String) async throws -> PharmacyAuthenticatedSession
}
