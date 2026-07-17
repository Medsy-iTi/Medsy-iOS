//
//  PharmacyAccountType.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

enum PharmacyAccountType: String, CaseIterable, Identifiable {
    case owner
    case pharmacist

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .owner:
            "pharmacy.auth.account_type.owner.title"
        case .pharmacist:
            "pharmacy.auth.account_type.pharmacist.title"
        }
    }

    var descriptionKey: String {
        switch self {
        case .owner:
            "pharmacy.auth.account_type.owner.description"
        case .pharmacist:
            "pharmacy.auth.account_type.pharmacist.description"
        }
    }

    var systemImage: String {
        switch self {
        case .owner:
            "building.2"
        case .pharmacist:
            "cross.case"
        }
    }
}
