//
//  AiChatViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import Foundation
import SwiftUI
import UserNotifications

// MARK: - Protocol

protocol AiChatViewModelProtocol: AnyObject {
    var messages: [AiChatMessage] { get }
    var inputText: String { get set }
    var isSending: Bool { get }
    var isLoadingHistory: Bool { get }
    var historyLoadFailed: Bool { get }
    var errorMessage: String? { get }
    var selectedImage: UIImage? { get set }
    var isRecording: Bool { get }
    var isSendEnabled: Bool { get }
    func onAppear()
    func sendText()
    func sendSuggestion(_ text: String)
    func sendWithImage()
    func startNewChat()
    func retryMessage(id: Int)
    func retryLastFailedMessage()
    func dismissError()
    func toggleRecording()
    func prefillPrompt(_ text: String)
    func clearDraftPrompt()
    var onOpenCategory: ((Int, String) -> Void)? { get set }
    var onOpenCart: (() -> Void)? { get set }
    var onOpenCompleteRequest: (([AIChatProduct]) -> Void)? { get set }
    var onOpenProductDetails: ((Int) -> Void)? { get set }
    var onOpenReminders: (() -> Void)? { get set }
    var onCartNeedsRefresh: (() -> Void)? { get set }
}

// MARK: - Implementation

@MainActor
@Observable
final class AiChatViewModel: AiChatViewModelProtocol {

    // MARK: - Exposed state
    private(set) var messages: [AiChatMessage] = []
    var inputText: String = ""
    private(set) var isSending: Bool = false
    private(set) var isLoadingHistory: Bool = false
    private(set) var historyLoadFailed: Bool = false
    private(set) var errorMessage: String? = nil
    var selectedImage: UIImage? = nil
    private(set) var isRecording: Bool = false

    var isSendEnabled: Bool {
        !isSending &&
        (selectedImage != nil || !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: - Navigation callbacks
    var onOpenCategory: ((Int, String) -> Void)?
    var onOpenCart: (() -> Void)?
    var onOpenCompleteRequest: (([AIChatProduct]) -> Void)?
    var onOpenProductDetails: ((Int) -> Void)?
    var onOpenReminders: (() -> Void)?
    var onCartNeedsRefresh: (() -> Void)?

    // MARK: - Dependencies
    private let sendTextUseCase: SendAiChatTextMessageUseCaseProtocol
    private let sendImageUseCase: SendAiChatImageMessageUseCaseProtocol
    private let loadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol
    private let startNewChatUseCase: StartNewAiChatUseCaseProtocol
    private let session: AIChatSessionDataSource
    private let speechRecognizer: AiChatSpeechRecognizer
    private let reminderStore: ReminderStore?
    private let reminderScheduler: ReminderScheduler

    // MARK: - Internal tracking
    private var activeTask: Task<Void, Never>?
    private var pendingRetryUserID: Int? = nil  // tracks which optimistic bubble is being retried

    // MARK: - Init

    init(
        sendTextUseCase: SendAiChatTextMessageUseCaseProtocol,
        sendImageUseCase: SendAiChatImageMessageUseCaseProtocol,
        loadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol,
        startNewChatUseCase: StartNewAiChatUseCaseProtocol,
        session: AIChatSessionDataSource,
        speechRecognizer: AiChatSpeechRecognizer,
        reminderStore: ReminderStore? = nil,
        reminderScheduler: ReminderScheduler = .shared
    ) {
        self.sendTextUseCase = sendTextUseCase
        self.sendImageUseCase = sendImageUseCase
        self.loadHistoryUseCase = loadHistoryUseCase
        self.startNewChatUseCase = startNewChatUseCase
        self.session = session
        self.speechRecognizer = speechRecognizer
        self.reminderStore = reminderStore
        self.reminderScheduler = reminderScheduler
    }

    // MARK: - Lifecycle

    func onAppear() {
        guard !session.isHistoryLoaded else { return }
        loadHistory()
    }

    func prefillPrompt(_ text: String) {
        inputText = String(text.prefix(500))
    }

    func clearDraftPrompt() {
        inputText = ""
        selectedImage = nil
    }

    // MARK: - History

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

    // MARK: - Send text

    func sendText() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let maxLength = 500
        guard !text.isEmpty, isSendEnabled else { return }
        markHistoryUnavailableIfNeeded()
        let capped = text.count > maxLength
            ? String(text.prefix(maxLength))
            : text
        inputText = ""
        performSend(text: capped, image: nil, existingUserID: nil)
    }

    // MARK: - Send suggestion (bypasses history-loaded gate)

    /// Sends a pre-defined suggestion prompt immediately.
    /// Forces history to mark-as-failed if not yet loaded so the user
    /// doesn't have to wait for history before tapping a suggestion.
    func sendSuggestion(_ text: String) {
        guard !isSending, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if !session.isHistoryLoaded {
            session.markHistoryFailed()
            isLoadingHistory = false
        }
        inputText = ""
        performSend(text: text, image: nil, existingUserID: nil)
    }

    // MARK: - Send image

    func sendWithImage() {
        guard let image = selectedImage, isSendEnabled else { return }
        markHistoryUnavailableIfNeeded()
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        selectedImage = nil
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        performSend(text: text.isEmpty ? nil : text, image: imageData, existingUserID: nil)
    }
    // MARK: - Retry

    func retryMessage(id: Int) {
        guard !isSending else { return }
        guard let msg = session.messages.first(where: { $0.id == id }),
              msg.isRetryable else { return }
        session.beginRetry(userMessageID: id)
        syncMessages()
        let imageData: Data? = nil  // image not preserved on retry
        performSend(text: msg.text, image: imageData, existingUserID: id)
    }

    func retryLastFailedMessage() {
        guard let message = session.messages.last(where: { $0.isRetryable }) else {
            dismissError()
            return
        }
        retryMessage(id: message.id)
    }
    
    // MARK: - Make Order / Complete Request
    
    func confirmRequest(action: AIChatAction?, fallbackProducts: [AIChatProduct]) {
        var resolvedProducts: [AIChatProduct] = []
        let ids = action?.addedProductIDs ?? []
        
        if !ids.isEmpty {
            // Find products with these IDs from chat history
            let allProducts = messages.flatMap { $0.products }
            var uniqueProducts = [Int: AIChatProduct]()
            for p in allProducts {
                uniqueProducts[p.id] = p
            }
            resolvedProducts = ids.compactMap { uniqueProducts[$0] }
        } else {
            // If the backend didn't specify IDs, but sent products in the current message
            resolvedProducts = fallbackProducts
        }
        
        // If still empty, grab the most recently discussed products in the chat
        if resolvedProducts.isEmpty {
            let recentProducts = messages.reversed().flatMap { $0.products }
            var uniqueProducts = [Int: AIChatProduct]()
            var orderedProducts: [AIChatProduct] = []
            for p in recentProducts {
                if uniqueProducts[p.id] == nil {
                    uniqueProducts[p.id] = p
                    orderedProducts.append(p)
                }
            }
            // Just grab the most recent product(s) if we had to fallback this far
            resolvedProducts = orderedProducts
        }
        
        onOpenCompleteRequest?(resolvedProducts)
    }

    // MARK: - New chat

    func startNewChat() {
        activeTask?.cancel()
        activeTask = nil
        Task {
            try? await startNewChatUseCase.execute()
        }
        session.reset()
        clearDraftPrompt()
        syncMessages()
        isSending = false
        errorMessage = nil
    }

    // MARK: - Errors

    func dismissError() { errorMessage = nil }

    // MARK: - Speech

    func toggleRecording() {
        if isRecording {
            speechRecognizer.stop()
            isRecording = false
        } else {
            speechRecognizer.start { [weak self] partial in
                guard let self else { return }
                Task { @MainActor in
                    self.inputText = partial
                }
            } onFinished: { [weak self] final in
                guard let self else { return }
                Task { @MainActor in
                    self.inputText = final
                    self.isRecording = false
                }
            } onError: { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.isRecording = false
                    self.errorMessage = "chatbot.mic.error".localized
                }
            }
            isRecording = true
        }
    }

    // MARK: - Core send logic

    private func performSend(text: String?, image: Data?, existingUserID: Int?) {
        let capturedGeneration = session.generation

        // Append or reuse the optimistic user bubble
        let userID: Int
        if let existingID = existingUserID {
            userID = existingID
        } else {
            // For image messages, use a placeholder label and store the image data
            // so the bubble can render a real thumbnail instead of an icon string.
            let label = text ?? "chatbot.camera.image_preview".localized
            userID = session.appendOptimisticUserMessage(text: label, imageData: image)
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
                    response = try await sendTextUseCase.execute(text: text ?? "", analyticsPreset: nil)
                }

                guard !Task.isCancelled else { return }
                
                // Save image locally if we got a valid response with IDs
                if let image = image, let convID = response.conversationID, let msgID = response.messageID {
                    AIChatImageStore.saveImage(image, conversationID: convID, messageID: msgID)
                }
                
                session.resolveResponse(response, typingID: typingID, sentGeneration: capturedGeneration)
                syncMessages()
                handleAction(response.action)
                handleReminder(response.reminder)
            } catch {
                guard !Task.isCancelled else { return }
                session.removeTypingIndicator(id: typingID)
                session.markRetryable(userMessageID: userID)
                syncMessages()
                errorMessage = localizedError(error)
            }
            isSending = false
        }
    }

    private func markHistoryUnavailableIfNeeded() {
        guard !session.isHistoryLoaded else { return }
        session.markHistoryFailed()
        isLoadingHistory = false
    }

    // MARK: - Action side-effects

    private func handleAction(_ action: AIChatAction?) {
        guard let action else { return }
        switch action.type {
        case .addedToCart:
            // Tell the UI to immediately refresh the cart state in the background
            onCartNeedsRefresh?()
            break
        case .createRequest:
            // Do NOT auto-navigate — just signal availability via the card
            break
        }
    }

    // MARK: - Reminder side-effects

    private func handleReminder(_ reminder: AIChatReminder?) {
        guard let reminder else { return }
        // Persist the reminder locally and schedule system notifications.
        // This is a fire-and-forget Task — if scheduling fails the chat response
        // is still shown (the answer text always describes what was set).
        Task {
            if let store = reminderStore {
                let saved = await MainActor.run {
                    store.insert(
                        medicineName: reminder.medicineName,
                        times: reminder.times,
                        durationDays: reminder.durationDays
                    )
                }
                await reminderScheduler.schedule(reminder: saved)
            } else {
                // No store injected (e.g. preview) — still request permission for UX.
                await reminderScheduler.requestAuthorization()
            }
        }
    }

    // MARK: - Sync session → published

    private func syncMessages() {
        messages = session.messages
    }

    // MARK: - Error localization

    private func localizedError(_ error: Error) -> String {
        if let netErr = error as? NetworkError {
            switch netErr {
            case .validationError(let msg):
                return msg.isEmpty ? "chatbot.error.generic".localized : "chatbot.error.generic".localized
            case .unauthorized:
                return "chatbot.error.generic".localized
            default:
                return "chatbot.error.generic".localized
            }
        }
        return "chatbot.error.generic".localized
    }
}
