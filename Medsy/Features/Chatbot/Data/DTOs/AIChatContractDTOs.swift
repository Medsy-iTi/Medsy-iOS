//
//  AIChatContractDTOs.swift
//  Medsy
//

struct AIChatMessageResponseDTO: Decodable {
    let conversationId: Int?
    let messageId: Int?
    let intent: String
    let answer: String
    let products: [AIChatProductDTO]?
    let alternatives: [AIChatProductDTO]?
    let doctorSpecializations: [String]?
    let emergencyNumbers: [AIChatEmergencyNumberDTO]?
    let categories: [AIChatCategoryDTO]?
    let pharmacistRankings: [AIChatPharmacistRankingDTO]?
    let disclaimer: String?
    let action: AIChatActionDTO?
}

struct AIChatProductDTO: Decodable {
    let id: Int?
    let name: String?
    let productName: String?
    let strength: String?
    let packSize: String?
    let form: String?
    let price: Double?
    let scientificName: String?
    let scientificCategory: String?
    let categoryId: Int?
    let consumerCategory: String?
    let company: String?
    let route: String?
    let description: String?
    let imageUrl: String?
}

struct AIChatEmergencyNumberDTO: Decodable {
    let service: String?
    let number: String?
}

struct AIChatCategoryDTO: Decodable {
    let id: Int?
    let name: String?
}

struct AIChatActionDTO: Decodable {
    let type: String?
    let addedProductIds: [Int]?
    let quantity: Int?
    let cartItemCount: Int?
}

struct AIChatPharmacistRankingDTO: Decodable {
    let metric: String?
    let period: String?
    let entries: [AIChatPharmacistPerformanceEntryDTO]?
}

struct AIChatPharmacistPerformanceEntryDTO: Decodable {
    let rank: Int?
    let pharmacistId: Int?
    let firstName: String?
    let lastName: String?
    let count: Int?
}

struct AIChatHistoryResponseDTO: Decodable {
    let conversationId: Int?
    let messages: [AIChatHistoryMessageDTO]?
}

struct AIChatHistoryMessageDTO: Decodable {
    let id: Int
    let role: String
    let content: String
    let intent: String?
    let products: [AIChatProductDTO]?
    let alternatives: [AIChatProductDTO]?
    let doctorSpecializations: [String]?
    let emergencyNumbers: [AIChatEmergencyNumberDTO]?
    let categories: [AIChatCategoryDTO]?
    let pharmacistRankings: [AIChatPharmacistRankingDTO]?
    let createdAt: String?
}

struct AIChatCartInteractionsResponseDTO: Decodable {
    let warnings: [AIChatInteractionWarningDTO]?
}

struct AIChatInteractionWarningDTO: Decodable {
    let severity: String?
    let title: String?
    let advice: String?
    let involvedProducts: [AIChatInteractionProductDTO]?
}

struct AIChatInteractionProductDTO: Decodable {
    let productId: Int?
    let productName: String?
    let ingredient: String?
}
