//
//  CustomerProfile.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

struct CustomerProfile: Equatable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let homeAddress: String?
    let dateOfBirth: Date?
    let phoneNumber: String

    var fullName: String {
        [firstName, lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

struct UpdateCustomerProfileInput: Equatable {
    let firstName: String
    let lastName: String
    let homeAddress: String
    let dateOfBirth: Date?
}
