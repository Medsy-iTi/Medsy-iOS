//
//  AIChatContractModels.swift
//  Medsy
//

import Foundation

enum AIChatIntent: Equatable, Sendable {
    case greeting
    case medicineRequest
    case symptomAdvice
    case doctorSpecialization
    case emergency
    case medicineUsage
    case categoryBrowse
    case addToCart
    case createRequest
    case setReminder
    case pharmacistPerformance
    case pharmacyAnalytics
    case other
}

enum AIChatMessageRole: Equatable, Sendable {
    case user
    case assistant
    case unknown(String)
}

struct AIChatProduct: Identifiable, Equatable, Sendable, Hashable {
    let id: Int
    let name: String
    let productName: String?
    let strength: String?
    let packSize: String?
    let form: String?
    let price: Double
    let scientificName: String?
    let scientificCategory: String?
    let categoryID: Int?
    let consumerCategory: String?
    let company: String?
    let route: String?
    let description: String?
    let imageURL: String?
}

struct AIChatEmergencyNumber: Equatable, Sendable {
    enum Service: Equatable, Sendable {
        case ambulance
        case police
        case fire
    }

    let service: Service
    let number: String
}

struct AIChatCategory: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
}

struct AIChatAction: Equatable, Sendable {
    enum ActionType: Equatable, Sendable {
        case addedToCart
        case createRequest
    }

    let type: ActionType
    let addedProductIDs: [Int]
    let quantity: Int?
    let cartItemCount: Int?
}

enum AIChatPerformanceMetric: Equatable, Hashable, Sendable {
    case offersCreated
    case successfulOrders
    case unknown(String)
}

enum AIChatPerformancePeriod: Equatable, Hashable, Sendable {
    case lastDay
    case lastWeek
    case lastMonth
    case lastYear
    case unknown(String)
}

enum AIChatPerformanceDirection: Equatable, Hashable, Sendable {
    case top
    case bottom
    case unknown(String)
}

struct AIChatPharmacistPerformanceEntry: Equatable, Sendable {
    let rank: Int
    let pharmacistID: Int
    let firstName: String
    let lastName: String
    let count: Int
}

struct AIChatPharmacistRanking: Equatable, Sendable {
    let metric: AIChatPerformanceMetric
    let period: AIChatPerformancePeriod
    let direction: AIChatPerformanceDirection
    let entries: [AIChatPharmacistPerformanceEntry]
}

struct AIChatReminder: Equatable, Sendable {
    /// Display name for the medicine (e.g. "Concor").
    let medicineName: String
    /// One or more 24-hour "HH:mm" strings (already resolved server-side).
    let times: [String]
    /// How many days the medication course lasts.
    let durationDays: Int
}

struct AIChatAssistantResponse: Equatable, Sendable {
    let conversationID: Int?
    let messageID: Int?
    let intent: AIChatIntent
    let answer: String
    let products: [AIChatProduct]
    let alternatives: [AIChatProduct]
    let doctorSpecializations: [String]
    let emergencyNumbers: [AIChatEmergencyNumber]
    let categories: [AIChatCategory]
    let pharmacistRankings: [AIChatPharmacistRanking]
    let disclaimer: String?
    let action: AIChatAction?
    /// One-shot scheduling instruction; never replayed from history.
    let reminder: AIChatReminder?
    let analytics: AIChatAnalytics?
}

struct AIChatHistory: Equatable, Sendable {
    let conversationID: Int?
    let messages: [AIChatHistoryMessage]
}

struct AIChatHistoryMessage: Identifiable, Equatable, Sendable {
    let id: Int
    let role: AIChatMessageRole
    let content: String
    let intent: AIChatIntent?
    let products: [AIChatProduct]
    let alternatives: [AIChatProduct]
    let doctorSpecializations: [String]
    let emergencyNumbers: [AIChatEmergencyNumber]
    let categories: [AIChatCategory]
    let pharmacistRankings: [AIChatPharmacistRanking]
    let analytics: AIChatAnalytics?
    let createdAt: Date?
}

enum AIChatInteractionSeverity: Equatable, Sendable {
    case high
    case moderate
}

struct AIChatInteractionProduct: Equatable, Sendable {
    let productID: Int
    let productName: String
    let ingredient: String?
}

struct AIChatInteractionWarning: Equatable, Sendable {
    let severity: AIChatInteractionSeverity
    let title: String
    let advice: String
    let involvedProducts: [AIChatInteractionProduct]
}

// MARK: - Analytics

enum AiAnalyticsPreset: String, Equatable, Sendable {
    case pharmacyMonthOverview = "PHARMACY_MONTH_OVERVIEW"
    case pharmacyMonthAcceptance = "PHARMACY_MONTH_ACCEPTANCE"
    case pharmacyMonthTopEmployee = "PHARMACY_MONTH_TOP_EMPLOYEE"
    case pharmacyMonthLargestOrder = "PHARMACY_MONTH_LARGEST_ORDER"
    case selfMonthOverview = "SELF_MONTH_OVERVIEW"
    case selfMonthOrders = "SELF_MONTH_ORDERS"
}

struct AIChatAnalytics: Equatable, Sendable {
    let schemaVersion: Int
    let scope: String
    let period: String
    let start: Date?
    let end: Date?
    let metrics: [AIChatAnalyticsMetric]
    let breakdowns: [AIChatAnalyticsBreakdown]
    let rankings: [AIChatPharmacistPerformanceEntry]
    let orderHighlights: [AIChatAnalyticsOrderHighlight]
    let topProducts: [AIChatAnalyticsTopProduct]
}

struct AIChatAnalyticsMetric: Equatable, Sendable {
    let key: String
    let value: Double
    let unit: String
    let previousValue: Double?
    let deltaPercent: Double?
}

struct AIChatAnalyticsBreakdown: Equatable, Sendable {
    let group: String
    let key: String
    let count: Int
}

struct AIChatAnalyticsOrderHighlight: Equatable, Sendable {
    let orderId: Int
    let status: String
    let totalPrice: Double
    let date: Date?
}

struct AIChatAnalyticsTopProduct: Equatable, Sendable {
    let productId: Int
    let productName: String
    let quantity: Int
    let orderCount: Int
    let revenue: Double
}
