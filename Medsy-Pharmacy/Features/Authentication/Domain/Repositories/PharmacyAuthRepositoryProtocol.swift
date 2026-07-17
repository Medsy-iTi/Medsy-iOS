//  PharmacyAuthRepositoryProtocol.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

protocol PharmacyAuthRepositoryProtocol {
    func login(input: LoginInput) async throws -> AuthenticatedSession
}
