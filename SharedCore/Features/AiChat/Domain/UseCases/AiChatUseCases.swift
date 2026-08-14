//
//  AiChatUseCases.swift
//  SharedCore
//
//  All four AI chat use-case protocols and implementations in one file
//  so SharedCore stays lean.

import Foundation

// MARK: - Send text

protocol SendAiChatTextMessageUseCaseProtocol: Sendable {
    func execute(text: String, analyticsPreset: String?) async throws -> AIChatAssistantResponse
}

final class SendAiChatTextMessageUseCase: SendAiChatTextMessageUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String, analyticsPreset: String?) async throws -> AIChatAssistantResponse {
        try await repository.sendTextMessage(text: text, analyticsPreset: analyticsPreset)
    }
}

// MARK: - Send image

protocol SendAiChatImageMessageUseCaseProtocol: Sendable {
    func execute(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse
}

final class SendAiChatImageMessageUseCase: SendAiChatImageMessageUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse {
        try await repository.sendImageMessage(imageData: imageData, mimeType: mimeType, message: message)
    }
}

// MARK: - Load history

protocol LoadAiChatHistoryUseCaseProtocol: Sendable {
    func execute() async throws -> AIChatHistory
}

final class LoadAiChatHistoryUseCase: LoadAiChatHistoryUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AIChatHistory {
        try await repository.loadHistory()
    }
}

// MARK: - Start new chat (delete history)

protocol StartNewAiChatUseCaseProtocol: Sendable {
    func execute() async throws
}

final class StartNewAiChatUseCase: StartNewAiChatUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.deleteHistory()
    }
}
