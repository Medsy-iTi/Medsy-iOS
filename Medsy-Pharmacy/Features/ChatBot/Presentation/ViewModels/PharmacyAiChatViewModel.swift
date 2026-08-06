//
//  PharmacyAiChatViewModel.swift
//  Medsy-Pharmacy
//
//  Pharmacy-specific AI chat view model.
//  Key differences from the customer app:
//  - No cart callbacks (pharmacy admin doesn't add to cart)
//  - No speech recognizer (mic omitted)
//  - PHARMACIST_PERFORMANCE cards are visible to pharmacy admins
//  - handleAction() is a no-op (neither action type applies to pharmacy)

import Foundation
import SwiftUI

// MARK: - Protocol

protocol PharmacyAiChatViewModelProtocol: AnyObject {
    var messages: [AiChatMessage] { get }
    var inputText: String { get set }
    var isSending: Bool { get }
    var isLoadingHistory: Bool { get }
    var historyLoadFailed: Bool { get }
    var errorMessage: String? { get }
    var selectedImage: UIImage? { get set }
    var isSendEnabled: Bool { get }
    func onAppear()
    func sendText()
    func sendSuggestion(_ text: String)
    func sendWithImage()
    func startNewChat()
    func retryMessage(id: Int)
    func dismissError()
    // Navigation callbacks wired by the root view
    var onOpenCategory: ((Int, String) -> Void)? { get set }
}

// MARK: - Implementation

@MainActor
@Observable
final class PharmacyAiChatViewModel: PharmacyAiChatViewModelProtocol {

    // MARK: Exposed state
    private(set) var messages: [AiChatMessage] = []
    var inputText: String = ""
    private(set) var isSending: Bool = false
    private(set) var isLoadingHistory: Bool = false
    private(set) var historyLoadFailed: Bool = false
    private(set) var errorMessage: String? = nil
    var selectedImage: UIImage? = nil

    var isSendEnabled: Bool {
        !isSending &&
        session.isHistoryLoaded &&
        (selectedImage != nil || !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: Navigation callbacks
    var onOpenCategory: ((Int, String) -> Void)?

    // MARK: Dependencies
    private let sendTextUseCase: SendAiChatTextMessageUseCaseProtocol
    private let sendImageUseCase: SendAiChatImageMessageUseCaseProtocol
    private let loadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol
    private let startNewChatUseCase: StartNewAiChatUseCaseProtocol
    let session: AIChatSessionDataSource

    // MARK: Internal tracking
    private var activeTask: Task<Void, Never>?
    private var pendingRetryUserID: Int? = nil

    // MARK: Init

    init(
        sendTextUseCase: SendAiChatTextMessageUseCaseProtocol,
        sendImageUseCase: SendAiChatImageMessageUseCaseProtocol,
        loadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol,
        startNewChatUseCase: StartNewAiChatUseCaseProtocol,
        session: AIChatSessionDataSource
    ) {
        self.sendTextUseCase = sendTextUseCase
        self.sendImageUseCase = sendImageUseCase
        self.loadHistoryUseCase = loadHistoryUseCase
        self.startNewChatUseCase = startNewChatUseCase
        self.session = session
    }

    // MARK: Lifecycle

    func onAppear() {
        guard !session.isHistoryLoaded else { return }
        loadHistory()
    }

    // MARK: History

    private func loadHistory() {
        isLoadingHistory = true
        historyLoadFailed = false
        Task {
            do {
                let history = try await loadHistoryUseCase.execute()
                session.hydrateHistory(history)
                syncMessages()
            } catch {
                session.markHistoryFailed()
                historyLoadFailed = true
                syncMessages()
            }
            isLoadingHistory = false
        }
    }

    // MARK: Send text

    func sendText() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let maxLength = 500
        guard !text.isEmpty, isSendEnabled else { return }
        let capped = text.count > maxLength ? String(text.prefix(maxLength)) : text
        inputText = ""
        performSend(text: capped, image: nil, existingUserID: nil)
    }

    // MARK: Send suggestion (bypasses history-loaded gate)

    func sendSuggestion(_ text: String) {
        guard !isSending, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if !session.isHistoryLoaded {
            session.markHistoryFailed()
            isLoadingHistory = false
        }
        inputText = ""
        performSend(text: text, image: nil, existingUserID: nil)
    }

    // MARK: Send image

    func sendWithImage() {
        guard let image = selectedImage, isSendEnabled else { return }
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        selectedImage = nil
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        performSend(text: text.isEmpty ? nil : text, image: imageData, existingUserID: nil)
    }

    // MARK: Retry

    func retryMessage(id: Int) {
        guard let msg = session.messages.first(where: { $0.id == id }),
              msg.isRetryable else { return }
        session.beginRetry(userMessageID: id)
        syncMessages()
        performSend(text: msg.text, image: nil, existingUserID: id)
    }

    // MARK: New chat

    func startNewChat() {
        activeTask?.cancel()
        activeTask = nil
        Task { try? await startNewChatUseCase.execute() }
        session.reset()
        syncMessages()
        isSending = false
        errorMessage = nil
    }

    // MARK: Errors

    func dismissError() { errorMessage = nil }

    // MARK: Core send logic

    private func performSend(text: String?, image: Data?, existingUserID: Int?) {
        let capturedGeneration = session.generation

        let userID: Int
        if let existingID = existingUserID {
            userID = existingID
        } else {
            let label = text ?? "pharmacy.chatbot.camera.image_preview".localized
            userID = session.appendOptimisticUserMessage(text: label)
        }
        let typingID = session.appendTypingIndicator()
        syncMessages()
        isSending = true
        errorMessage = nil

        activeTask = Task {
            do {
                let response: AIChatAssistantResponse
                if let image {
                    response = try await sendImageUseCase.execute(
                        imageData: image,
                        mimeType: "image/jpeg",
                        message: text
                    )
                } else {
                    response = try await sendTextUseCase.execute(text: text ?? "")
                }

                guard !Task.isCancelled else { return }
                session.resolveResponse(response, typingID: typingID, sentGeneration: capturedGeneration)
                syncMessages()
                // Pharmacy: no cart or request-confirm side effects
            } catch {
                guard !Task.isCancelled else { return }
                session.removeTypingIndicator(id: typingID)
                session.markRetryable(userMessageID: userID)
                syncMessages()
                errorMessage = "pharmacy.chatbot.error.generic".localized
            }
            isSending = false
        }
    }

    // MARK: Sync session → published

    private func syncMessages() {
        messages = session.messages
    }
}
