//
//  PharmacyRegistrationInput.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

struct PharmacyRegistrationInput: Equatable {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let password: String
    let homeAddress: String
    let dateOfBirth: Date
}
