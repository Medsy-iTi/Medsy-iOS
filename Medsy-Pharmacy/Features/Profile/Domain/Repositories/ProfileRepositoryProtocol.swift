//
//  ProfileRepositoryProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


protocol ProfileRepositoryProtocol {
    func fetchProfile() async throws -> PharmacyProfile



    func logout() async throws
}
