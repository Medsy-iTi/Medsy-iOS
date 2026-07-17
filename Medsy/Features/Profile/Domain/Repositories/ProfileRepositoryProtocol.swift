//
//  ProfileRepositoryProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol ProfileRepositoryProtocol {
    func fetchProfile() async throws -> CustomerProfile
    func updateProfile(input: UpdateCustomerProfileInput) async throws -> CustomerProfile
}
