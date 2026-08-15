//
//  AIDashboardSummary.swift
//  Medsy-Pharmacy
//

import Foundation

struct AIDashboardSummary: Equatable, Sendable {
    let period: PharmacyDashboardPeriod
    let language: String
    let summary: String
    let generatedAt: Date?
    let cached: Bool
}
