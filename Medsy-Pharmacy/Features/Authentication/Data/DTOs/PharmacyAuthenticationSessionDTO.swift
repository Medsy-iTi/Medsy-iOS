//
//  PharmacyAuthenticationSessionDTO.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyAuthenticationSessionResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
    let data: PharmacyAuthenticationSessionDTO?
}

struct PharmacyAuthenticationSessionDTO: Decodable, Equatable {
    let accessToken: String
    let refreshToken: String
    let user: PharmacyAuthenticatedUserDTO

    func toDomain() -> PharmacyAuthenticatedSession {
        PharmacyAuthenticatedSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            user: user.toDomain()
        )
    }
}

struct PharmacyAuthenticatedUserDTO: Decodable, Equatable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    let homeAddress: String?
    let dob: String?

    func toDomain() -> PharmacyAuthenticatedUser {
        PharmacyAuthenticatedUser(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role,
            homeAddress: homeAddress,
            dateOfBirth: dob
        )
    }
}
