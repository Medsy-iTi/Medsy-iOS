//
//  PharmacyMapper.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation

enum PharmacyMapper {
    static func map(_ dto: PharmacyDataDTO) -> Pharmacy {
        Pharmacy(
            id: dto.id,
            name: dto.name,
            latitude: dto.latitude,
            longitude: dto.longitude,
            address: dto.address,
            phoneNumber: dto.phoneNumber
        )
    }
}
