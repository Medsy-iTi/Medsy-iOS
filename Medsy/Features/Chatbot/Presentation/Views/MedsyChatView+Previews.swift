//
//  MedsyChatView+Previews.swift
//  Medsy
//

import SwiftUI

#Preview("Chat – Empty (Light)") {
    MedsyChatPreviewWrapper()
}

#Preview("Chat – Dark / Arabic") {
    MedsyChatPreviewWrapper(isDark: true, isArabic: true)
}

struct MedsyChatPreviewWrapper: View {
    var isDark: Bool = false
    var isArabic: Bool = false
    
    @State private var vm: AiChatViewModel
    private var lang = LanguageManager.shared
    
    init(isDark: Bool = false, isArabic: Bool = false) {
        self.isDark = isDark
        self.isArabic = isArabic
        
        let session = AIChatSessionDataSource()
        _vm = State(initialValue: AiChatViewModel(
            sendTextUseCase: PreviewSendTextUseCase(),
            sendImageUseCase: PreviewSendImageUseCase(),
            loadHistoryUseCase: PreviewLoadHistoryUseCase(),
            startNewChatUseCase: PreviewStartNewChatUseCase(),
            session: session,
            speechRecognizer: AiChatSpeechRecognizer()
        ))
    }
    
    var body: some View {
        NavigationStack {
            MedsyChatView(viewModel: vm)
                .environment(lang)
                .localizedEnvironment()
                .preferredColorScheme(isDark ? .dark : .light)
        }
        .onAppear {
            AppSettings.shared.isDarkMode = isDark
            if isArabic {
                lang.set(.arabic)
            } else {
                lang.set(.english)
            }
        }
    }
}

// MARK: - Preview fakes

struct PreviewSendTextUseCase: SendAiChatTextMessageUseCaseProtocol {
    func execute(text: String) async throws -> AIChatAssistantResponse {
        try await Task.sleep(nanoseconds: 800_000_000)
        return AIChatAssistantResponse(
            conversationID: 1, messageID: 1, intent: .other,
            answer: "This is a preview response.", products: [], alternatives: [],
            doctorSpecializations: [], emergencyNumbers: [],
            categories: [], pharmacistRankings: [], disclaimer: nil, action: nil, reminder: nil
        )
    }
}

struct PreviewSendImageUseCase: SendAiChatImageMessageUseCaseProtocol {
    func execute(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse {
        return AIChatAssistantResponse(
            conversationID: 1, messageID: 1, intent: .other,
            answer: "Image received.", products: [], alternatives: [],
            doctorSpecializations: [], emergencyNumbers: [],
            categories: [], pharmacistRankings: [], disclaimer: nil, action: nil, reminder: nil
        )
    }
}

struct PreviewLoadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol {
    func execute() async throws -> AIChatHistory {
        return AIChatHistory(conversationID: nil, messages: [])
    }
}

struct PreviewStartNewChatUseCase: StartNewAiChatUseCaseProtocol {
    func execute() async throws {}
}
