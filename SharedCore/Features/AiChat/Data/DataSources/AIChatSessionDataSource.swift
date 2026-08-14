import Foundation

@MainActor
final class AIChatSessionDataSource {

    private(set) var messages: [AiChatMessage] = []
    private(set) var isHistoryLoaded: Bool = false
    private(set) var generation: Int = 0
    private var nextLocalID: Int = -1

    func hydrateHistory(_ history: AIChatHistory) {
        guard !isHistoryLoaded else { return }
        isHistoryLoaded = true
        var hydrated: [AiChatMessage] = []
        
        for (index, msg) in history.messages.enumerated() {
            var imageData: Data? = nil
            
            // Check if this user message has a locally cached image upload
            if msg.role == .user, let convID = history.conversationID {
                // Peek at the next message to get the assistant's ID
                if index + 1 < history.messages.count {
                    let nextMsg = history.messages[index + 1]
                    if nextMsg.role == .assistant {
                        imageData = AIChatImageStore.loadImage(conversationID: convID, messageID: nextMsg.id)
                    }
                }
            }
            
            hydrated.append(AiChatMessage(
                id: msg.id,
                role: msg.role,
                text: msg.content,
                intent: msg.intent,
                assistantResponse: nil,
                historyMessage: msg,
                isTyping: false,
                isRetryable: false,
                localGeneration: generation,
                attachedImageData: imageData,
                analyticsPreset: nil
            ))
        }
        messages = hydrated
    }

    func markHistoryFailed() {
        isHistoryLoaded = true
    }

    func appendOptimisticUserMessage(text: String, imageData: Data? = nil, analyticsPreset: String? = nil) -> Int {
        let id = nextLocalID
        nextLocalID -= 1
        let msg = AiChatMessage(
            id: id,
            role: .user,
            text: text,
            intent: nil,
            assistantResponse: nil,
            historyMessage: nil,
            isTyping: false,
            isRetryable: false,
            localGeneration: generation,
            attachedImageData: imageData,
            analyticsPreset: analyticsPreset
        )
        messages.append(msg)
        return id
    }

    /// Appends a typing indicator placeholder and returns its ID.
    func appendTypingIndicator() -> Int {
        let id = nextLocalID
        nextLocalID -= 1
        let msg = AiChatMessage(
            id: id,
            role: .assistant,
            text: "",
            intent: nil,
            assistantResponse: nil,
            historyMessage: nil,
            isTyping: true,
            isRetryable: false,
            localGeneration: generation,
            attachedImageData: nil,
            analyticsPreset: nil
        )
        messages.append(msg)
        return id
    }

    func resolveResponse(_ response: AIChatAssistantResponse, typingID: Int, sentGeneration: Int) {
        guard sentGeneration == generation else { return }
        messages.removeAll { $0.id == typingID }
        let serverID = response.messageID ?? nextLocalID
        if response.messageID == nil { nextLocalID -= 1 }
        let msg = AiChatMessage(
            id: serverID,
            role: .assistant,
            text: response.answer,
            intent: response.intent,
            assistantResponse: response,
            historyMessage: nil,
            isTyping: false,
            isRetryable: false,
            localGeneration: generation,
            attachedImageData: nil,
            analyticsPreset: nil
        )
        messages.append(msg)
    }

    func markRetryable(userMessageID: Int) {
        if let idx = messages.firstIndex(where: { $0.id == userMessageID }) {
            messages[idx] = messages[idx].retryable()
        }
    }

    func beginRetry(userMessageID: Int) {
        if let idx = messages.firstIndex(where: { $0.id == userMessageID }) {
            messages[idx] = messages[idx].clearRetryable()
        }
    }
  
    func removeTypingIndicator(id: Int) {
        messages.removeAll { $0.id == id }
    }

    // MARK: - New chat

    func reset() {
        messages = []
        isHistoryLoaded = false
        generation += 1
        nextLocalID = -1
    }
}
