//
//  MedicineAnalyzeRepositoryProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation

protocol MedicineAnalyzeRepositoryProtocol {
    func analyze(imageData: Data, language: String) async throws -> [AnalyzedMedicineProduct]
}
