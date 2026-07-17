//
//  PharmacyRegistrationDTO.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

struct PharmacyRegistrationRequestDTO: Encodable, Equatable {
    let email: String
    let phoneNumber: String
    let firstName: String
    let lastName: String
    let password: String
    let role: String
    let homeAddress: String
    let dob: String

    init(input: PharmacyRegistrationInput) {
        email = input.email
        phoneNumber = input.phoneNumber
        firstName = input.firstName
        lastName = input.lastName
        password = input.password
        role = "PHARMACIST"
        homeAddress = input.homeAddress
        dob = Self.formatDate(input.dateOfBirth)
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct PharmacyRegistrationResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
}
