//
//  MedsyAIRoute.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


enum ChatbotRoute: Hashable {
    case chatDetail
    case medicineDetails(medicineId: String)
    case pharmacyMap
}
