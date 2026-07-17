//
//  RefreshTokenRepositoryProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol RefreshTokenRepositoryProtocol {
    func refresh(refreshToken: String) async throws -> AuthenticatedSession
}
