//
//  PharmacyAuthenticatedSession.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyAuthenticatedSession: Equatable {
    let accessToken: String
    let refreshToken: String
    let user: PharmacyAuthenticatedUser
}

struct PharmacyAuthenticatedUser: Equatable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    let homeAddress: String?
    let dateOfBirth: String?
}
