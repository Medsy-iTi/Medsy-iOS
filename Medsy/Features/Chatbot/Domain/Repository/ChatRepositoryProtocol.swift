import Foundation

// Legacy catalog chatbot repository (kept for build compatibility)
protocol ChatRepositoryProtocol: Sendable {
    func sendMessage(_ text: String, lang: String, limit: Int) async throws -> ChatMessage
    func fetchChatHistory() async throws -> [ChatMessage]
}
// AIChatRepositoryProtocol is now in SharedCore/Features/AiChat/Domain/Repository/
