//
//  ProfileRoute.swift
//  Medsy-Pharmacy
//

import Foundation

enum ProfileRoute: Hashable {
    case editProfile
    case editPharmacy
    case editPharmacist(PharmacistMember)
    case personalProfileDetail
    case pharmacyDetail
    case pharmacistsList
    case invitePharmacist
    case inviteSuccess(InviteSuccessInfo)
    case pharmacistProfile(PharmacistMember)
    case settings
}

enum ProfileSheet: Identifiable {
    case editProfile
    case editPharmacy
    case editPharmacist(PharmacistMember)
    case pharmacistOptions(PharmacistMember)
    case removePharmacist(PharmacistMember)

    var id: String {
        switch self {
        case .editProfile: return "editProfile"
        case .editPharmacy: return "editPharmacy"
        case let .editPharmacist(member): return "editPharmacist-\(member.id)"
        case let .pharmacistOptions(member): return "pharmacistOptions-\(member.id)"
        case let .removePharmacist(member): return "removePharmacist-\(member.id)"
        }
    }
}
