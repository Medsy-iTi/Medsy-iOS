//
//  ManagedPharmacy.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

struct ManagedPharmacy: Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let phoneNumber: String?
    let isAdmin: Bool
    let pharmacists: [ManagedPharmacyMember]
}

struct ManagedPharmacyMember: Identifiable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let isAdmin: Bool
}
