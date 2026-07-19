//
//  ProfileRepositoryProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//

import Foundation


protocol ProfileRepositoryProtocol {
    func fetchProfile() async throws -> PharmacyProfile
    func updateProfile(id: Int, email: String, firstName: String, lastName: String, homeAddress: String?, dateOfBirth: Date?) async throws



    func logout() async throws
}
