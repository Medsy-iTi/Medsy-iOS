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
    var isRecording: Bool { get }
    func onAppear()
    func sendText()
    func sendSuggestion(_ text: String)
    func sendWithImage()
    func startNewChat()
    func retryMessage(id: Int)
    func dismissError()
    func toggleRecording()
    // Navigation callbacks wired by the root view
    var onOpenCategory: ((Int, String) -> Void)? { get set }
    var onOpenProductDetails: ((Int) -> Void)? { get set }
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
    private(set) var isRecording: Bool = false
    private(set) var quickActions: [AiAnalyticsPreset] = []

    var isSendEnabled: Bool {
        !isSending &&
        session.isHistoryLoaded &&
        (selectedImage != nil || !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: Navigation callbacks
    var onOpenCategory: ((Int, String) -> Void)?
    var onOpenProductDetails: ((Int) -> Void)?

    // MARK: Dependencies
    private let sendTextUseCase: SendAiChatTextMessageUseCaseProtocol
    private let sendImageUseCase: SendAiChatImageMessageUseCaseProtocol
    private let loadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol
    private let startNewChatUseCase: StartNewAiChatUseCaseProtocol
    private let getMembershipUseCase: GetPharmacyMembershipUseCaseProtocol
    let session: AIChatSessionDataSource
    private let speechRecognizer: PharmacySpeechRecognizer

    // MARK: Internal tracking
    private var activeTask: Task<Void, Never>?
    private var pendingRetryUserID: Int? = nil

    // MARK: Init

    init(
        sendTextUseCase: SendAiChatTextMessageUseCaseProtocol,
        sendImageUseCase: SendAiChatImageMessageUseCaseProtocol,
        loadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol,
        startNewChatUseCase: StartNewAiChatUseCaseProtocol,
        session: AIChatSessionDataSource,
        getMembershipUseCase: GetPharmacyMembershipUseCaseProtocol,
        speechRecognizer: PharmacySpeechRecognizer = PharmacySpeechRecognizer()
    ) {
        self.sendTextUseCase = sendTextUseCase
        self.sendImageUseCase = sendImageUseCase
        self.loadHistoryUseCase = loadHistoryUseCase
        self.startNewChatUseCase = startNewChatUseCase
        self.session = session
        self.getMembershipUseCase = getMembershipUseCase
        self.speechRecognizer = speechRecognizer
    }

    // MARK: Lifecycle

    func onAppear() {
        Task {
            await updateQuickActions()
        }
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

    // MARK: - Analytics Presets
    
    private func updateQuickActions() async {
        let isAdmin = (try? await getMembershipUseCase.execute())?.isAdmin == true
        if isAdmin {
            quickActions = [
                .pharmacyMonthOverview,
                .pharmacyMonthAcceptance,
                .pharmacyMonthTopEmployee,
                .pharmacyMonthLargestOrder
            ]
        } else {
            quickActions = [
                .selfMonthOverview,
                .selfMonthOrders
            ]
        }
    }
    
    func sendPreset(_ preset: AiAnalyticsPreset) {
        let label = presetLabel(for: preset)
        inputText = ""
        performSend(text: label, image: nil, existingUserID: nil, analyticsPreset: preset.rawValue)
    }
    
    private func presetLabel(for preset: AiAnalyticsPreset) -> String {
        switch preset {
        case .pharmacyMonthOverview: return "pharmacy.chatbot.analytics.preset.month_overview".localized
        case .pharmacyMonthAcceptance: return "pharmacy.chatbot.analytics.preset.month_acceptance".localized
        case .pharmacyMonthTopEmployee: return "pharmacy.chatbot.analytics.preset.top_employee".localized
        case .pharmacyMonthLargestOrder: return "pharmacy.chatbot.analytics.preset.largest_order".localized
        case .selfMonthOverview: return "pharmacy.chatbot.analytics.preset.self_overview".localized
        case .selfMonthOrders: return "pharmacy.chatbot.analytics.preset.self_orders".localized
        }
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
        isLoadingHistory = false
        errorMessage = nil
    }

    // MARK: Errors

    func dismissError() { errorMessage = nil }

    // MARK: Speech

    func toggleRecording() {
        if isRecording {
            speechRecognizer.stop()
            isRecording = false
        } else {
            speechRecognizer.start { [weak self] partial in
                guard let self else { return }
                Task { @MainActor in self.inputText = partial }
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
                    self.errorMessage = "pharmacy.chatbot.mic.error".localized
                }
            }
            isRecording = true
        }
    }

    // MARK: Core send logic

    private func performSend(text: String?, image: Data?, existingUserID: Int?, analyticsPreset: String? = nil) {
        let capturedGeneration = session.generation

        let userID: Int
        if let existingID = existingUserID {
            userID = existingID
        } else {
            if let image = image {
                let label = text ?? "pharmacy.chatbot.camera.image_preview".localized
                userID = session.appendOptimisticUserMessage(text: label, imageData: image)
            } else {
                userID = session.appendOptimisticUserMessage(text: text ?? "", imageData: nil, analyticsPreset: analyticsPreset)
            }
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
                    response = try await sendTextUseCase.execute(text: text ?? "", analyticsPreset: analyticsPreset)
                }

                guard !Task.isCancelled else { return }
                
                if let image = image, let convID = response.conversationID, let msgID = response.messageID {
                    AIChatImageStore.saveImage(image, conversationID: convID, messageID: msgID)
                }

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
