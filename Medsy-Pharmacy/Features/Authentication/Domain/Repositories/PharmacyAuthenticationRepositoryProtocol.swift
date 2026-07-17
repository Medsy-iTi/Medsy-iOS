//
//  PharmacyAuthenticationRepositoryProtocol.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol PharmacyAuthenticationRepositoryProtocol {
    func register(input: PharmacyRegistrationInput) async throws
    func verify(input: PharmacyVerificationInput) async throws -> PharmacyAuthenticatedSession
}
