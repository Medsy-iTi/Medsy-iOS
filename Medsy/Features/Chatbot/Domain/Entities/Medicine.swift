//
//  Medicine.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//

import Foundation
struct Medicine: Identifiable, Sendable {
    let id: String
    let name: String
    let dosage: String
    let price: Double
    let matchPercentage: Int?
}
