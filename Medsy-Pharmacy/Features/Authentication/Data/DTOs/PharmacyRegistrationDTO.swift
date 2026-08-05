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
    let pharmacyId: Int?

    private enum CodingKeys: String, CodingKey {
        case email
        case phoneNumber
        case firstName
        case lastName
        case password
        case role
        case homeAddress
        case dob
        case pharmacyId
    }

    init(input: PharmacyRegistrationInput) {
        email = input.email
        phoneNumber = input.phoneNumber
        firstName = input.firstName
        lastName = input.lastName
        password = input.password
        role = "PHARMACIST"
        homeAddress = input.homeAddress
        dob = Self.formatDate(input.dateOfBirth)
        pharmacyId = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(password, forKey: .password)
        try container.encode(role, forKey: .role)
        try container.encode(homeAddress, forKey: .homeAddress)
        try container.encode(dob, forKey: .dob)
        try container.encodeNil(forKey: .pharmacyId)
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
