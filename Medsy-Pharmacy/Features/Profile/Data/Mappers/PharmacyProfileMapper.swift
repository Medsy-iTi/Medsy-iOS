//
//  PharmacyProfileMapper.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

enum PharmacyProfileMapper {
    static func toDomain(
        pharmacist: PharmacistResponseDTO,
        pharmacy: PharmacyMineResponseDTO?
    ) -> PharmacyProfile {
        PharmacyProfile(
            id: String(pharmacist.id),
            firstName: pharmacist.firstName,
            lastName: pharmacist.lastName,
            email: pharmacist.email,
            phoneNumber: pharmacist.phoneNumber,
            pharmacyId: pharmacist.pharmacyId,
            isPharmacyAdmin: pharmacist.pharmacyAdmin,
            pharmacyName: pharmacy?.name,
            pharmacyAddress: pharmacy?.address,
            pharmacyPhoneNumber: pharmacy?.phoneNumber
        )
    }
}