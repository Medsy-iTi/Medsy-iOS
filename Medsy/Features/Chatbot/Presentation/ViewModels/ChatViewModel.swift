
//
//  ChatViewModel.swift
//  Medsy
//

import Foundation



protocol ChatViewModelProtocol: AnyObject {
    var messages: [ChatMessage] { get }
    var inputText: String { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var limit: Int { get set }
    var onNavigateToDetails: ((String) -> Void)? { get set }
    func loadHistory()
    func sendMessage()
    func dismissError()
    func addToCart(source: AICatalogSource)
}


@MainActor
@Observable
final class ChatViewModel: ChatViewModelProtocol {



    private(set) var messages:      [ChatMessage] = []
    var inputText:                   String = ""
    private(set) var isLoading:      Bool = false
    private(set) var errorMessage:   String?
    var limit: Int = 5
    var onNavigateToDetails: ((String) -> Void)?


    private let sendMessageUseCase:      SendMessageUseCaseProtocol
    private let fetchChatHistoryUseCase: FetchChatHistoryUseCaseProtocol
    private let addCartItemUseCase:      AddCartItemUseCaseProtocol
    private let languageManager:         LanguageManager

    init(
        sendMessageUseCase:      SendMessageUseCaseProtocol,
        fetchChatHistoryUseCase: FetchChatHistoryUseCaseProtocol,
        addCartItemUseCase:      AddCartItemUseCaseProtocol,
        languageManager:         LanguageManager
    ) {
        self.sendMessageUseCase      = sendMessageUseCase
        self.fetchChatHistoryUseCase = fetchChatHistoryUseCase
        self.addCartItemUseCase      = addCartItemUseCase
        self.languageManager         = languageManager
    }


    func loadHistory() {
        Task {
            do {
                let history = try await fetchChatHistoryUseCase.execute()
                self.messages = history
            } catch {

            }
        }
    }

    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !isLoading else { return }
        let userMsg = ChatMessage(
            id:         UUID().uuidString,
            text:       trimmedText,
            sender:     .user,
            timestamp:  Date(),
            customCard: .none
        )
        messages.append(userMsg)
        inputText = ""
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let currentLang = languageManager.languageCode
                let aiMsg = try await sendMessageUseCase.execute(
                    text:  trimmedText,
                    lang:  currentLang,
                    limit: limit
                )
                self.messages.append(aiMsg)
            } catch {
                self.errorMessage = localizedError(error)
            }
            self.isLoading = false
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    func addToCart(source: AICatalogSource) {
        Task {
            do {
                let input = AddCartItemInput(
                    productID: Int64(source.product.id), 
                    quantity: 1, 
                    dosageInfo: source.product.strength ?? ""
                )
                _ = try await addCartItemUseCase.execute(input: input)
            } catch {
                self.errorMessage = localizedError(error)
            }
        }
    }


    private func localizedError(_ error: Error) -> String {
        switch error {
        case NetworkError.validationError(let message):
            return message.isEmpty ? "chatbot.error.generic".localized : message
        case NetworkError.unauthorized:
            return "chatbot.error.generic".localized
        default:
            return "chatbot.error.generic".localized
        }
    }
}
