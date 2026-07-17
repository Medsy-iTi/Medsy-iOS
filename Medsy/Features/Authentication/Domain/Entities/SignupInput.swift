//
//  SignupInput.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Foundation

struct SignupInput: Equatable {
    let email: String
    let phoneNumber: String
    let firstName: String
    let lastName: String
    let password: String
    let homeAddress: String
    let dateOfBirth: Date
}
