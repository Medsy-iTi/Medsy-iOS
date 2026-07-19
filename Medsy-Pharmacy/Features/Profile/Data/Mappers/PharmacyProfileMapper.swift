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
            homeAddress: pharmacist.homeAddress,
            dateOfBirth: {
                if let dobString = pharmacist.dob {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.date(from: dobString)
                }
                return nil
            }(),
            pharmacyName: pharmacy?.name,
            pharmacyAddress: pharmacy?.address,
            pharmacyPhoneNumber: pharmacy?.phoneNumber,
            pharmacyMembers: (pharmacy?.pharmacists ?? []).map {
                PharmacistMember(
                    id: $0.id,
                    firstName: $0.firstName,
                    lastName: $0.lastName,
                    email: $0.email,
                    phoneNumber: $0.phoneNumber,
                    isAdmin: $0.isAdmin
                )
            }
        )
    }
}