//
//  ProfileRoute.swift
//  Medsy-Pharmacy
//

import Foundation

enum ProfileRoute: Hashable {
    case editProfile
    case editPharmacy
    case editPharmacist(PharmacistMember)
}
