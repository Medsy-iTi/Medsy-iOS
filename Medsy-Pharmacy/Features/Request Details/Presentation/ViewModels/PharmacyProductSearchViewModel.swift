// PharmacyProductSearchViewModel.swift

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyProductSearchViewModel {
    var searchQuery: String = ""
    private(set) var products: [PharmacyProductDTO] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil

    private let searchUseCase: SearchProductsUseCaseProtocol

    init(searchUseCase: SearchProductsUseCaseProtocol? = nil) {
        self.searchUseCase = searchUseCase ?? PharmacyAppAssembler.shared.container.resolve(SearchProductsUseCaseProtocol.self)
    }

    func performSearch() async {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            products = []
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            products = try await searchUseCase.execute(keyword: searchQuery, page: 0, size: 20)
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            products = []
        }
        isLoading = false
    }
}
