//
//  ChatViewModel.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//

import Foundation


@MainActor
@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let sendMessageUseCase: SendMessageUseCaseProtocol
    private let fetchChatHistoryUseCase: FetchChatHistoryUseCaseProtocol

    init(
        sendMessageUseCase: SendMessageUseCaseProtocol,
        fetchChatHistoryUseCase: FetchChatHistoryUseCaseProtocol
    ) {
        self.sendMessageUseCase = sendMessageUseCase
        self.fetchChatHistoryUseCase = fetchChatHistoryUseCase
    }

    func loadHistory() {
        Task {
            do {
                self.messages = try await fetchChatHistoryUseCase.execute()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let userMsg = ChatMessage(
            id: UUID().uuidString,
            text: trimmedText,
            sender: .user,
            timestamp: Date(),
            customCard: .none
        )
        
        messages.append(userMsg)
        inputText = ""
        isLoading = true

        Task {
            do {
                let aiMsg = try await sendMessageUseCase.execute(text: trimmedText)
                self.messages.append(aiMsg)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
