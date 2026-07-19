//
//  PharmacyProfile.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

struct PharmacyProfile: Equatable, Identifiable {
    let id: String
    let name: String
    let isVerified: Bool
    let rating: Double
    let ratingCount: Int
    let avatarURL: URL?

    let phoneNumber: String
    let licenseSummary: String
    let registeredAddress: String

    let isAcceptingOrders: Bool
    let language: PharmacyAppLanguage
    let isDarkModeEnabled: Bool

   
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
}

#if DEBUG
extension PharmacyProfile {
    static let preview = PharmacyProfile(
        id: "1",
        name: "صيدلية النهضية",
        isVerified: true,
        rating: 4.8,
        ratingCount: 128,
        avatarURL: nil,
        phoneNumber: "010 1234 5678",
        licenseSummary: "عرض رخصة مزاولة المهنة",
        registeredAddress: "شارع النيل، المعادي، القاهرة",
        isAcceptingOrders: true,
        language: .arabic,
        isDarkModeEnabled: false
    )
}
#endif
