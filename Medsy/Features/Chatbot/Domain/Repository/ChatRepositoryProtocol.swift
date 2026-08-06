import Foundation

protocol ChatRepositoryProtocol: Sendable {
    func sendMessage(_ text: String, lang: String, limit: Int) async throws -> ChatMessage
    func fetchChatHistory() async throws -> [ChatMessage]
}

protocol AIChatRepositoryProtocol: Sendable {
    func sendTextMessage(_ text: String) async throws -> AIChatAssistantResponse
    func sendImageMessage(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse
    func loadHistory() async throws -> AIChatHistory
    func deleteHistory() async throws
    func getCartInteractions() async throws -> [AIChatInteractionWarning]
}
