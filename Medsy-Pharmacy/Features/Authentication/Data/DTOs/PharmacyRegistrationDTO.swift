//
//  PharmacyRegistrationDTO.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyRegistrationRequestDTO: Encodable, Equatable {
    let email: String
    let phoneNumber: String
    let firstName: String
    let lastName: String
    let password: String
    let role: String

    init(input: PharmacyRegistrationInput) {
        email = input.email
        phoneNumber = input.phoneNumber
        firstName = input.firstName
        lastName = input.lastName
        password = input.password
        role = "PHARMACIST"
    }
}

struct PharmacyRegistrationResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
}
