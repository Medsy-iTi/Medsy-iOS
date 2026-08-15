//
//  AIDashboardSummaryDTO.swift
//  Medsy-Pharmacy
//

import Foundation

struct AIDashboardSummaryEnvelopeDTO: Decodable {
    let success: Bool
    let message: String
    let data: AIDashboardSummaryDTO?
}

struct AIDashboardSummaryDTO: Decodable {
    let period: String?
    let language: String?
    let summary: String
    let generatedAt: String?
    let cached: Bool?
}
