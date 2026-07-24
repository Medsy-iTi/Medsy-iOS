//
//  ChatRepository.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import Foundation

final class ChatRepository: ChatRepositoryProtocol, @unchecked Sendable {
    
    func sendMessage(_ text: String) async throws -> ChatMessage {
        // Mock response simulating AI behavior
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return ChatMessage(
            id: UUID().uuidString,
            text: "This sounds like a tension headache from eye strain.",
            sender: .ai,
            timestamp: Date(),
            customCard: .medicineSuggestion(
                medicine: Medicine(
                    id: UUID().uuidString,
                    name: "Panadol Extra",
                    dosage: "500 mg · 24 tablets",
                    price: 68.0,
                    matchPercentage: 98
                )
            )
        )
    }

    func fetchChatHistory() async throws -> [ChatMessage] {
        return []
    }
}