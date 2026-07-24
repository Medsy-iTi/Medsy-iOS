//
//  MedicineAnalyzeViewState.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

enum MedicineAnalyzeViewState: Equatable {
    case sourceSelection
    case preview
    case analyzing
    case results
    case noMatches
    case failure(String)
}

enum MedicineAnalyzeEffect {
    case exit
}
