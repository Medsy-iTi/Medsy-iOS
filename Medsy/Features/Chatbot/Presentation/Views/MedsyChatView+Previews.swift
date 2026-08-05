//
//  MedsyChatView+Previews.swift
//  Medsy
//

import SwiftUI

#Preview("Chat – Empty (Light)") {
    let lang = LanguageManager.shared
    let vm = ChatViewModel(
        sendMessageUseCase:      PreviewSendMessageUseCase(),
        fetchChatHistoryUseCase: PreviewFetchChatHistoryUseCase(),
        addCartItemUseCase:      PreviewAddCartItemUseCase(),
        languageManager:         lang
    )
    return NavigationStack {
        MedsyChatView(viewModel: vm)
            .environment(lang)
            .localizedEnvironment()
    }
}

#Preview("Chat – Dark / Arabic") {
    let lang = LanguageManager.shared
    AppSettings.shared.isDarkMode = true
    lang.set(.arabic)
    let vm = ChatViewModel(
        sendMessageUseCase:      PreviewSendMessageUseCase(),
        fetchChatHistoryUseCase: PreviewFetchChatHistoryUseCase(),
        addCartItemUseCase:      PreviewAddCartItemUseCase(),
        languageManager:         lang
    )
    return NavigationStack {
        MedsyChatView(viewModel: vm)
            .environment(lang)
            .localizedEnvironment()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Preview fakes

struct PreviewAddCartItemUseCase: AddCartItemUseCaseProtocol {
    func execute(input: AddCartItemInput) async throws -> Cart {
        throw NetworkError.validationError("Preview Error")
    }
}

struct PreviewSendMessageUseCase: SendMessageUseCaseProtocol {
    func execute(text: String, lang: String, limit: Int) async throws -> ChatMessage {
        try await Task.sleep(nanoseconds: 800_000_000)
        return ChatMessage(id: UUID().uuidString, text: "This is a preview response.", sender: .ai, timestamp: Date(), customCard: .none)
    }
}

struct PreviewFetchChatHistoryUseCase: FetchChatHistoryUseCaseProtocol {
    func execute() async throws -> [ChatMessage] { [] }
}
