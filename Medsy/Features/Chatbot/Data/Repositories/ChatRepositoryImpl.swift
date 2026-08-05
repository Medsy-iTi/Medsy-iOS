
//
//  ChatRepositoryImpl.swift
//  Medsy
//


final class ChatRepositoryImpl: ChatRepositoryProtocol, @unchecked Sendable {

    private let dataSource: CatalogAskDataSourceProtocol

    init(dataSource: CatalogAskDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func sendMessage(_ text: String, lang: String, limit: Int) async throws -> ChatMessage {
        let requestDTO = CatalogAskRequestDTO(
            question: text,
            lang:     lang,
            limit:    limit
        )

        let responseDTO = try await dataSource.ask(request: requestDTO)
        return CatalogAskMapper.map(responseDTO, userText: text)
    }

    func fetchChatHistory() async throws -> [ChatMessage] {
     
        return []
    }
}
