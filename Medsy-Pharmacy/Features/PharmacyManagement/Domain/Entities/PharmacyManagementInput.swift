//
//  PharmacyManagementInput.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

struct PharmacyLicenseFile: Equatable {
    let fileName: String
    let data: Data
    let mimeType: String
}

struct CreatePharmacyInput: Equatable {
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let phoneNumber: String?
    let license: PharmacyLicenseFile
}

struct UpdatePharmacyInput: Equatable {
    let id: Int
    let name: String?
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let phoneNumber: String?
}
