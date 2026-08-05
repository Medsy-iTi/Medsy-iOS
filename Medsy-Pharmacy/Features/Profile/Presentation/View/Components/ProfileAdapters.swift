//
//  ProfileAdapters.swift
//  Medsy-Pharmacy
//
//  Adapter components to bridge existing data models with new profile views
//

import SwiftUI

// MARK: - Pharmacist Adapter

extension PharmacistMember {
    func toPharmacist() -> Pharmacist {
        Pharmacist(
            id: String(id),
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: isAdmin ? .admin : .pharmacist,
            isVerified: true, // Assuming verified for now
            yearsOfExperience: 0, // Not available in current model
            avatarURLString: nil
        )
    }
}

struct Pharmacist {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let role: PharmacistRole
    let isVerified: Bool
    let yearsOfExperience: Int
    let avatarURLString: String?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var avatarURL: URL? {
        guard let urlString = avatarURLString else { return nil }
        return URL(string: urlString)
    }
}

enum PharmacistRole {
    case admin
    case pharmacist
    
    var isAdmin: Bool {
        self == .admin
    }
}

// MARK: - PharmacySummary Adapter

extension PharmacyProfile {
    func toPharmacySummary() -> PharmacySummary {
        PharmacySummary(
            id: String(pharmacyId ?? 0),
            name: pharmacyName ?? "pharmacy_card.unknown".localized,
            address: pharmacyAddress ?? "",
            phoneNumber: pharmacyPhoneNumber ?? "",
            isVerified: true,
            pharmacistsCount: pharmacyMembers.count
        )
    }
    
    func toPharmacist() -> Pharmacist {
        Pharmacist(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: isPharmacyAdmin ? .admin : .pharmacist,
            isVerified: true,
            yearsOfExperience: 0, // Not available in current model
            avatarURLString: nil
        )
    }
}

struct PharmacySummary {
    let id: String
    let name: String
    let address: String
    let phoneNumber: String
    let isVerified: Bool
    let pharmacistsCount: Int
}
