//
//  PharmacyInvitation.swift
//  Medsy-Pharmacy
//

import Foundation

struct PharmacyInvitation: Equatable, Hashable {
    let id: Int
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacistId: Int
    let pharmacistFirstName: String
    let pharmacistLastName: String
    let status: String
    let invitedEmail: String

    var pharmacistFullName: String {
        "\(pharmacistFirstName) \(pharmacistLastName)"
    }
}

struct InviteSuccessInfo: Hashable {
    let email: String
    let pharmacyName: String
}
