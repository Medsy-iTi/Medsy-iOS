//  LoginDTO.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

struct LoginRequestDTO: Encodable, Equatable {
    let email: String
    let password: String

    init(input: LoginInput) {
        self.email = input.email
        self.password = input.password
    }
}
