//
//  AuthRepositoryProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol AuthRepositoryProtocol {
    func register(input: SignupInput) async throws
}
