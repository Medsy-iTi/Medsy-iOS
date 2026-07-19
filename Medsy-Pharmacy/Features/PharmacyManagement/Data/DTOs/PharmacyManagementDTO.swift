//
//  PharmacyManagementDTO.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

struct PharmacyManagementResponseDTO<Data: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: Data?
}

struct PharmacyMineDTO: Decodable, Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let phoneNumber: String?
    let isAdmin: Bool
    let pharmacists: [PharmacyMemberDTO]

    func toDomain() -> ManagedPharmacy {
        ManagedPharmacy(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            address: address,
            phoneNumber: phoneNumber,
            isAdmin: isAdmin,
            pharmacists: pharmacists.map { $0.toDomain() }
        )
    }
}

struct PharmacyMemberDTO: Decodable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let isAdmin: Bool

    func toDomain() -> ManagedPharmacyMember {
        ManagedPharmacyMember(
            id: id,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            email: email,
            isAdmin: isAdmin
        )
    }
}

struct PharmacyMutationDTO: Decodable, Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let phoneNumber: String?
}

struct PharmacyDeletionResponseDTO: Decodable {
    let success: Bool
    let message: String
}
