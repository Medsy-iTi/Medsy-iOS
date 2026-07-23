//
//  CustomerProfileMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

enum CustomerProfileMapper {
    static func map(_ dto: CustomerProfileDTO) -> CustomerProfile {
        CustomerProfile(
            id: dto.id,
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            homeAddress: dto.homeAddress,
            dateOfBirth: dto.dob.flatMap(ProfileDateMapper.date),
			homeLatitude: dto.latitude,
			homeLongitude: dto.longitude,
            phoneNumber: dto.phoneNumber
        )
    }
}
