//
//  PharmacyManagementDisplayModel.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

struct PharmacyManagementDisplayModel: Equatable {
    let id: Int
    let name: String
    let address: String
    let phoneNumber: String
    let latitude: Double
    let longitude: Double
    let isAdmin: Bool
    let pharmacists: [PharmacyTeamMemberDisplayModel]
}

struct PharmacyTeamMemberDisplayModel: Identifiable, Equatable {
    let id: Int
    let fullName: String
    let phoneNumber: String
    let email: String
    let isAdmin: Bool
}

struct PharmacyFormDraft: Equatable {
    var name = ""
    var phoneNumber = ""
    var address = ""
    var latitude: Double?
    var longitude: Double?
    var licenseFileName: String?
}

enum PharmacyManagementViewState: Equatable {
    case loading
    case unassigned
    case assigned(PharmacyManagementDisplayModel)
    case failure
}
