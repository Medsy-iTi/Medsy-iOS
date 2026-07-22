//
//  PharmacyProfile.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

struct PharmacyProfile: Equatable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let pharmacyId: Int?
    let isPharmacyAdmin: Bool
    let homeAddress: String?
    let dateOfBirth: Date?

    
    let pharmacyName: String?
    let pharmacyAddress: String?
    let pharmacyPhoneNumber: String?
    let pharmacyMembers: [PharmacistMember]

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

