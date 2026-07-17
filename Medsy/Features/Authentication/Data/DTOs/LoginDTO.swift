//
//  LoginDTO.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

struct LoginRequestDTO: Encodable, Equatable {
    let email: String
    let password: String

    init(input: LoginInput) {
        self.email = input.email
        self.password = input.password
    }
}
