//
//  PharmacistMember.swift
//  Medsy-Pharmacy
//

import Foundation

struct PharmacistMember: Equatable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let isAdmin: Bool

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
