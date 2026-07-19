//
//  PharmacyManagementRequestDTO.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

struct CreatePharmacyRequestDTO: Encodable, Equatable {
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let phoneNumber: String?

    init(input: CreatePharmacyInput) {
        name = input.name
        latitude = input.latitude
        longitude = input.longitude
        address = input.address
        phoneNumber = input.phoneNumber
    }
}

struct UpdatePharmacyRequestDTO: Encodable, Equatable {
    let name: String?
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let phoneNumber: String?

    init(input: UpdatePharmacyInput) {
        name = input.name
        latitude = input.latitude
        longitude = input.longitude
        address = input.address
        phoneNumber = input.phoneNumber
    }
}
