//
//  SignupDTO.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Foundation

struct SignupRequestDTO: Encodable, Equatable {
    let email: String
    let phoneNumber: String
    let firstName: String
    let lastName: String
    let password: String
    let role: String
    let homeAddress: String
    let dob: String
    let pharmacyId: Int

    init(input: SignupInput) {
        email = input.email
        phoneNumber = input.phoneNumber
        firstName = input.firstName
        lastName = input.lastName
        password = input.password
        role = "CUSTOMER"
        homeAddress = input.homeAddress
        dob = Self.formatDate(input.dateOfBirth)
        pharmacyId = 0
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

struct SignupResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
}
