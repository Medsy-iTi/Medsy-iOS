//
//  CustomCardType.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


enum CustomCardType: Sendable {
    case none
    case emergency(title: String, description: String, phoneNumber: String)
    case medicineSuggestion(medicine: Medicine)
    case alternativeMedicine(originalName: String, replacementName: String, savings: String)
    case reminder(medicineName: String, schedule: String)
    case catalogResult(sources: [AICatalogSource])
}
