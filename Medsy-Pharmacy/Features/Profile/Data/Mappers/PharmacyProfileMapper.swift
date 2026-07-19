//
//  PharmacyProfileMapper.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

enum PharmacyProfileMapper {
    static func toDomain(_ dto: PharmacyProfileDTO) -> PharmacyProfile {
        PharmacyProfile(
            id: dto.id,
            name: dto.name,
            isVerified: dto.isVerified,
            rating: dto.rating,
            ratingCount: dto.ratingCount,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            phoneNumber: dto.phoneNumber,
            licenseSummary: dto.licenseSummary,
            registeredAddress: dto.registeredAddress,
            isAcceptingOrders: dto.isAcceptingOrders,
            language: PharmacyAppLanguage(rawValue: dto.language) ?? .arabic,
            isDarkModeEnabled: dto.isDarkModeEnabled
        )
    }
}