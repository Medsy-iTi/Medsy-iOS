//
//  AuthSessionDTO.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

struct AuthSessionResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
    let data: AuthSessionDTO?
}

struct AuthSessionDTO: Decodable, Equatable {
    let accessToken: String
    let refreshToken: String
    let user: AuthenticatedUserDTO

    func toDomain() -> AuthenticatedSession {
        AuthenticatedSession(accessToken: accessToken, refreshToken: refreshToken, user: user.toDomain())
    }
}

struct AuthenticatedUserDTO: Decodable, Equatable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    let homeAddress: String
    let dob: String

    func toDomain() -> AuthenticatedUser {
        AuthenticatedUser(id: id, email: email, firstName: firstName, lastName: lastName, role: role, homeAddress: homeAddress, dateOfBirth: dob)
    }
}
