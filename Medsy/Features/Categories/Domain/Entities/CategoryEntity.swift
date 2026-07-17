//  CategoryEntity.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

import SwiftUI

struct CategoryResponse: Decodable {
    let success: Bool
    let message: String
    let data: CategoryData
}

struct CategoryData: Decodable {
    let content: [CategoryEntity]
    let pageNumber: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    let last: Bool
}

struct CategoryEntity: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String

    var displayName: String {
        name.lowercased().capitalized
    }

    var iconName: String {
        let lower = name.lowercased()
        if lower.contains("acne") {
            return "sparkles"
        } else if lower.contains("diabetic") {
            return "waveform.path.ecg"
        } else if lower.contains("analgesic") || lower.contains("analgesics") {
            return "pills.fill"
        } else if lower.contains("cough") {
            return "waveform.path.ecg"
        } else if lower.contains("vitamin") {
            return "pills"
        } else if lower.contains("antibiotic") {
            return "cross.fill"
        } else if lower.contains("antacid") {
            return "leaf.fill"
        } else if lower.contains("steroid") {
            return "syringe.fill"
        } else if lower.contains("allergic") {
            return "wind"
        } else {
            return "pills.fill"
        }
    }

    var iconColor: Color {
        let lower = name.lowercased()
        if lower.contains("acne") {
            return Color(hex: "#EC4899")
        } else if lower.contains("diabetic") {
            return Color(hex: "#06B6D4")
        } else if lower.contains("analgesic") || lower.contains("analgesics") {
            return Color(hex: "#3B82F6")
        } else if lower.contains("cough") {
            return Color(hex: "#10B981")
        } else if lower.contains("vitamin") {
            return Color(hex: "#F97316")
        } else if lower.contains("antibiotic") {
            return Color(hex: "#EF4444")
        } else if lower.contains("antacid") {
            return Color(hex: "#10B981")
        } else if lower.contains("steroid") {
            return Color(hex: "#8B5CF6")
        } else if lower.contains("allergic") {
            return Color(hex: "#F59E0B")
        } else {
            return Color(hex: "#3B82F6")
        }
    }

    var bgColor: Color {
        let lower = name.lowercased()
        if lower.contains("acne") {
            return Color(hex: "#FDF2F8")
        } else if lower.contains("diabetic") {
            return Color(hex: "#ECFEFF")
        } else if lower.contains("analgesic") || lower.contains("analgesics") {
            return Color(hex: "#EFF6FF")
        } else if lower.contains("cough") {
            return Color(hex: "#ECFDF5")
        } else if lower.contains("vitamin") {
            return Color(hex: "#FFF7ED")
        } else if lower.contains("antibiotic") {
            return Color(hex: "#FEF2F2")
        } else if lower.contains("antacid") {
            return Color(hex: "#ECFDF5")
        } else if lower.contains("steroid") {
            return Color(hex: "#F5F3FF")
        } else if lower.contains("allergic") {
            return Color(hex: "#FEF3C7")
        } else {
            return Color(hex: "#EFF6FF")
        }
    }
}
