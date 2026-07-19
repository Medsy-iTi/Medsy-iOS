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

#if DEBUG
extension PharmacyProfile {
    static let preview = PharmacyProfile(
        id: "1",
        firstName: "أحمد",
        lastName: "محمود",
        email: "ahmed@pharmacy.com",
        phoneNumber: "010 1234 5678",
        pharmacyId: 1,
        isPharmacyAdmin: true,
        homeAddress: "شارع النيل، المعادي، القاهرة",
        dateOfBirth: Date(),
        pharmacyName: "صيدلية النهضية",
        pharmacyAddress: "شارع النيل، المعادي، القاهرة",
        pharmacyPhoneNumber: "010 9876 5432",
        pharmacyMembers: []
    )
}
#endif
