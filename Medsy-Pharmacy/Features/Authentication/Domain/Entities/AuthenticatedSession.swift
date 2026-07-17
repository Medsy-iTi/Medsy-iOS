//  AuthenticatedSession.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

struct AuthenticatedSession: Equatable {
    let accessToken: String
    let refreshToken: String
    let user: AuthenticatedUser
}

struct AuthenticatedUser: Equatable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    let homeAddress: String
    let dateOfBirth: String
}
