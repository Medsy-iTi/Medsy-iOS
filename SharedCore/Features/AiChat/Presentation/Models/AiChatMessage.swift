import Foundation

/// Presentation-only chat message. Wraps both live responses and history replays.
struct AiChatMessage: Identifiable, Equatable, Sendable {
    let id: Int
    let role: AIChatMessageRole
    let text: String
    let intent: AIChatIntent?
    let assistantResponse: AIChatAssistantResponse?   // set for live assistant messages
    let historyMessage: AIChatHistoryMessage?          // set for history replays
    let isTyping: Bool
    let isRetryable: Bool
    let localGeneration: Int
    /// Compressed JPEG data for outgoing user image messages. Stored locally only — never persisted.
    let attachedImageData: Data?

    // MARK: - Derived helpers

    var products: [AIChatProduct] {
        assistantResponse?.products ?? historyMessage?.products ?? []
    }

    var doctorSpecializations: [String] {
        assistantResponse?.doctorSpecializations ?? historyMessage?.doctorSpecializations ?? []
    }

    var emergencyNumbers: [AIChatEmergencyNumber] {
        assistantResponse?.emergencyNumbers ?? historyMessage?.emergencyNumbers ?? []
    }

    var categories: [AIChatCategory] {
        assistantResponse?.categories ?? historyMessage?.categories ?? []
    }

    var alternatives: [AIChatProduct] {
        assistantResponse?.alternatives ?? historyMessage?.alternatives ?? []
    }

    var pharmacistRankings: [AIChatPharmacistRanking] {
        assistantResponse?.pharmacistRankings ?? historyMessage?.pharmacistRankings ?? []
    }

    var disclaimer: String? {
        assistantResponse?.disclaimer
    }

    var action: AIChatAction? {
        assistantResponse?.action   // never replay actions from history
    }

    var reminder: AIChatReminder? {
        assistantResponse?.reminder  // one-shot; never replayed from history
    }

    // MARK: - Mutation helpers (create new value)

    func retryable() -> AiChatMessage {
        AiChatMessage(
            id: id, role: role, text: text, intent: intent,
            assistantResponse: assistantResponse, historyMessage: historyMessage,
            isTyping: isTyping, isRetryable: true, localGeneration: localGeneration,
            attachedImageData: attachedImageData
        )
    }

    func clearRetryable() -> AiChatMessage {
        AiChatMessage(
            id: id, role: role, text: text, intent: intent,
            assistantResponse: assistantResponse, historyMessage: historyMessage,
            isTyping: isTyping, isRetryable: false, localGeneration: localGeneration,
            attachedImageData: attachedImageData
        )
    }
}
